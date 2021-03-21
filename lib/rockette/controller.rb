# frozen_string_literal: true

require_relative "controller/configurator"
# require_relative 'deployer'

module Rockette
  VALID_ACTIONS = %w[view deploy export configure quit].freeze
  # Manage Rockette in interactive mode
  class Controller
    def initialize
      @conf = Psych.load(File.read(CONF))
      @pastel = Pastel.new
      @prompt = TTY::Prompt.new
    end

    def launch!
      introduction

      if @conf["rockette"]["check_for_url"] && @conf["rockette"]["controller_url"].length < 10
        Rockette::Configurator.new.first_run
      end

      # input/action loop
      loop do
        action, args = actions
        break if action.downcase == "quit"

        do_action(action, args)
      end
      conclusion
    end

    private

    def introduction
      font = TTY::Font.new(:starwars)
      puts "-" * 85
      puts
      puts @pastel.yellow(font.write("Rockette"))
      puts
      puts "-" * 85
      puts "Rockette helps export and deploy APEX applications."
      puts
    end

    def conclusion
      puts
      puts "-" * 85
      puts @pastel.yellow("Have a good one!".upcase.center(85))
      puts "-" * 85
      puts
    end

    def actions
      response = @prompt.select("What would you like to do?", VALID_ACTIONS)
      args = response.downcase.strip.split
      action = args.shift
      [action, args]
    end

    def do_action(action, _args)
      case action
      when "view"
        puts "View Applications, Environments, or Registered Applications"
      when "deploy"
        puts "Deploy"
      when "export"
        puts "Export"
      when "configure"
        Rockette::Configurator.new.configure
      else
        puts "\nI don't understand that command.\n\n"
      end
    end
  end
end
