# frozen_string_literal: true

module Rockette
  # Configure Rockette application
  class Configurator < TTY::Config
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

    def self.configure
      puts "Please enter a number."
      choice = gets.chomp
      puts "You chose #{choice}."
    end

    def first_run
      puts
      puts "I see this is your first time running Rockette. Entering an APEX deployment"
      puts "uri will allow me to discover more about your environments."
      puts
      response = @prompt.yes?("Would you like to enter a URI?")
      if response == true
        uri = @prompt.ask("Please enter APEX deployment URI (base path):") do |u|
          u.validate(%r{^https://\w+.\w+})
        end
        @config.set(:rockette, :controller_url, value: uri)
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
