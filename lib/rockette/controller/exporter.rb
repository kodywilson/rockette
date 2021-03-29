# frozen_string_literal: true

require_relative "../text_helper"
require_relative "../commands/export"

module Rockette
  # Export and download APEX application
  class Exporter
    include TextHelper

    def initialize
      @pastel = Pastel.new
      @prompt = TTY::Prompt.new
      @spinner = TTY::Spinner.new
    end

    def launch!
      @conf = Psych.load(File.read(CONF))
      puts padder("Choose an application to download.")
      puts

      # input/action loop
      loop do
        enviros = Rockette::Viewer.new.environments
        list = list_builder(enviros)
        action = @prompt.select("Which environment is the app found?", list)
        break if action == list.length

        apps_url = enviros[action - 1]["deployment_api"]
        choose_app(apps_url)
      end
    end

    def do_export(app_id, apps_url)
      response = @prompt.yes?("Would you like to enter a filename for the export?")
      if response == true
        file = @prompt.ask("Please enter your desired filename:")
        options = Thor::CoreExt::HashWithIndifferentAccess.new "app_id" => app_id, "url" => apps_url, "file" => file,
                                                               "force" => true
      else
        puts padder("Saving under default file name: f#{app_id}.sql")
        options = Thor::CoreExt::HashWithIndifferentAccess.new "app_id" => app_id, "url" => apps_url, "force" => true
      end
      Rockette::Commands::Export.new(options).execute
      puts
    end

    protected

    def choose_app(apps_url)
      loop do
        apps = Rockette::Viewer.new.applications(apps_url)
        list = list_builder(apps)
        action = @prompt.slider("Download application => ", list, default: 1)
        break if action == list.length

        app_id = apps[action - 1]["application_id"]
        do_export(app_id, apps_url)
      end
    end

    def list_builder(array)
      names = [] # Start building selection list
      if array[0].key?("name")
        array.each { |n| names << n["name"] }
      else
        array.each { |n| names << "#{n["application_name"]}  App ID: #{n["application_id"]}" }
      end
      names << "Go Back"
      names.map.with_index { |n, x| [n, x + 1] }.to_h
    end
  end
end
