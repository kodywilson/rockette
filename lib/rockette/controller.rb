# frozen_string_literal: true

# require_relative 'configurator'
# require_relative 'deployer'

module Rockette
  VALID_ACTIONS = %w[view deploy export configure quit].freeze
  # Manage Rockette in interactive mode
  class Controller
    def initialize
      @prompt = TTY::Prompt.new
    end

    def launch!
      introduction

      do_action("configure", []) if CONF["rockette"]["check_for_url"]

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
      puts "-" * 60
      puts "Rockette".upcase.center(60)
      puts "-" * 60
      puts "This is an interactive program to help export and deploy APEX applications."
    end

    def conclusion
      puts "-" * 60
      puts "Have a good one!".upcase.center(60)
      puts "-" * 60
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
        puts "Configure"
      else
        puts "\nI don't understand that command.\n\n"
      end
    end
  end
end
