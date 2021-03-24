# frozen_string_literal: true

require_relative "../text_helper"

module Rockette
  # Configure Rockette application
  class Configurator
    include TextHelper

    attr_reader :config

    def initialize
      @config = TTY::Config.new
      @config.append_path APP_PATH
      @config.read

      @pastel = Pastel.new
      @prompt = TTY::Prompt.new
    end

    def self.config
      @config ||= self.class.new.config
    end

    def launch!
      puts
      puts @pastel.yellow("Configure Rockette here. Choosing 'editor' will let you edit the config file directly.")
      puts @pastel.yellow("Choose 'url' to enter a controller url, the api endpoint with your environments, etc.")
      puts
      # input/action loop
      loop do
        action = @prompt.select("What will it be?", %w[editor url back])
        break if action == "back"

        do_action(action)
      end
    end

    def do_action(action)
      case action
      when "editor"
        edit_config
      when "url"
        add_url
      else
        puts "\nI don't understand that command.\n\n"
      end
    end

    def add_url
      uri = @prompt.ask("Please enter APEX deployment URI (base path):") do |u|
        u.validate(%r{^https://\w+.\w+})
      end
      @config.set(:rockette, :controller_url, value: uri)
      @config.write(force: true)
      refresh_conf
    end

    def edit_config
      edit = TTY::Editor.open(CONF)
      puts "There seems to have been an issue trying to open the file: #{CONF}" unless edit
      refresh_conf if edit
    end

    def first_run
      puts
      puts "I see this is your first time running Rockette. Entering an APEX deployment"
      puts "uri will allow me to discover more about your environments."
      puts
      response = @prompt.yes?("Would you like to enter a URI?")
      if response == true
        add_url
      else
        response = @prompt.yes?("Would you like to disable these checks in the future?")
        @config.set(:rockette, :check_for_url, value: false) if response == true
      end
      @config.write(force: true) if response == true
      refresh_conf
    end

    def refresh_conf
      @config.read
    end
  end
end
