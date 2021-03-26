# frozen_string_literal: true

require_relative "../text_helper"
require_relative "../commands/deploy"

module Rockette
  # Push APEX application to target instance
  class Deployer
    include TextHelper

    def initialize
      @pastel = Pastel.new
      @prompt = TTY::Prompt.new
      @spinner = TTY::Spinner.new
    end

    def launch!
      @conf = Psych.load(File.read(CONF))
      intro_text

      # input/action loop
      loop do
        actions = { "🛸  Add" => 1, "📝  Update" => 2, "⬅️   Go Back" => 3 }
        response = @prompt.select("Add application or update an existing application?", actions)
        break if response == 3

        add_app if response == 1
        updater if response == 2
      end
      puts
    end

    protected

    def intro_text
      puts
      puts @pastel.yellow("These are the two available options:")
      print "1. Add application to an APEX instance. "
      print "It's #{@pastel.green.bold("generally safe and creates a new application")} from the export\n"
      print "2. Update an existing application with your chosen export. "
      print "#{@pastel.red.bold("Tread carefully")} with this option!\n"
      puts
    end

    def add_app
      puts padder("Let's choose an export to add")
      file = choose_file
      url = choose_env
      puts padder("You chose to add #{file} to the environment at #{url}")
      puts
      return unless @prompt.yes?("Proceed with the deployment?")

      options = Thor::CoreExt::HashWithIndifferentAccess.new "app_id" => "0", "url" => url, "file" => file,
                                                             "force" => true
      Rockette::Commands::Deploy.new(options).execute
      puts
    end

    def choose_app(apps_url)
      apps = Rockette::Viewer.new.applications(apps_url)
      list = list_builder(apps)
      action = @prompt.slider("Application to update => ", list, default: 1)

      apps[action - 1]
    end

    def choose_env
      enviros = Rockette::Viewer.new.environments
      list = list_builder(enviros)
      action = @prompt.select("Which environment?", list)
      enviros[action - 1]["deployment_api"]
    end

    def choose_file
      list = Dir.children(EXPORT_DIR)
      @prompt.select("Which export from #{EXPORT_DIR}?", list)
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

    def updater
      puts padder("Please choose the export with your updated application code")
      file = choose_file
      url = choose_env
      app = choose_app(url)
      puts "Application: #{app["application_name"]} | App ID: #{app["application_id"]} | Env URI: #{url}"
      puts "will be updated with the code from export: #{file}"
      puts
      return unless @prompt.yes?("Proceed with the deployment?")

      options = Thor::CoreExt::HashWithIndifferentAccess.new "app_id" => app["application_id"], "url" => url,
                                                             "file" => file, "force" => true
      Rockette::Commands::Deploy.new(options).execute
      puts
    end
  end
end
