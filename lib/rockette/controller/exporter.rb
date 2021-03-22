# frozen_string_literal: true

require_relative "../text_helper"

module Rockette
  # Export and download APEX application
  class Exporter
    include TextHelper

    def initialize
      @pastel = Pastel.new
      @prompt = TTY::Prompt.new
      @spinner = TTY::Spinner.new # ("[:spinner] Loading APEX environments ...", format: pulse_2)
      # @view_actions = {"🏔  APEX Environments" => 1, "🎭 Registered Applications" => 2, "⬅️  Go Back" => 3}
    end

    def launch!
      @conf = Psych.load(File.read(CONF))
      puts padder("Choose an application to download.")
      puts

      # input/action loop
      loop do
        enviros = Rockette::Viewer.new.environments
        names = [] # Start building selection list
        enviros.each { |n| names << n["name"] }
        names << "Go Back"
        list = names.map.with_index { |n, x| [n, x + 1] }.to_h
        action = @prompt.select("Which environment is the app found?", list)
        break if action == list.length

        apps_url = enviros[action - 1]["deployment_api"]
        loop do
          apps = Rockette::Viewer.new.applications(apps_url)
          list_items = []
          apps.each { |n| list_items << "#{n["application_name"]}  App ID: #{n["application_id"]}" }
          list_items << "Go Back"
          listy = list_items.map.with_index { |n, x| [n, x + 1] }.to_h
          action = @prompt.select("Which application would you like to download?", listy)
          break if action == listy.length

          app_id = apps[action - 1]["application_id"]
          do_action(app_id, apps_url)
        end
      end
    end

    def do_action(app_id, apps_url)
      url = apps_url[0...-7]
      response = @prompt.yes?("Would you like to enter a filename for the export?")
      if response == true
        file = @prompt.ask("Please enter your desired filename:")
        options = Thor::CoreExt::HashWithIndifferentAccess.new "app_id" => app_id, "url" => url, "file" => file, "force" => true
      else
        puts padder("Saving under default file name: f#{app_id}.sql")
        options = Thor::CoreExt::HashWithIndifferentAccess.new "app_id" => app_id, "url" => url, "force" => true
      end
      require_relative "../commands/export"
      Rockette::Commands::Export.new(options).execute
      puts
    end

    def environments
      uri = "#{@conf["rockette"]["controller_url"]}deploy/environments/"
      response = Rester.new(url: uri).rest_try
      bail unless response
      abort padder("#{uri} didn't work. Received: #{response.code}") unless response.code == 200
      @table_env = TTY::Table.new(header: ["Environment Name", "API", "Domain", "Owner", "Workspace"])
      JSON.parse(response.body)["items"].each do |h|
        @table_env << [h["name"], h["deployment_api"], h["domain"], h["owner"], h["workspace"]]
      end
    end

    def registered
      uri = "#{@conf["rockette"]["controller_url"]}deploy/registered_apps/"
      response = Rester.new(url: uri).rest_try
      bail unless response
      abort padder("#{uri} didn't work. Received: #{response.code}") unless response.code == 200
      @table_reg = TTY::Table.new(header: ["Registered Name", "Source App ID", "Source URI", "Target App ID",
                                           "Target URI"])
      JSON.parse(response.body)["items"].each do |h|
        @table_reg << [h["registered_name"], h["src_app_id"], h["src_url"], h["tgt_app_id"], h["tgt_url"]]
      end
    end
  end
end
