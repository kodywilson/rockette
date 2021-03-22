# frozen_string_literal: true

require_relative "controller/configurator"
require_relative "controller/exporter"
require_relative "controller/viewer"

module Rockette
  MAIN_ACTIONS = { "🔭  View Resources" => 1, "🚀  Deploy" => 2, "📥  Export" => 3,
                   "🛠   Configure" => 4, "❌  Quit" => 5 }.freeze
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
        action = actions
        break if action == 5

        do_action(action)
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
      @prompt.select("What would you like to do?", MAIN_ACTIONS)
    end

    def do_action(action)
      case action
      when 1
        viewer = Rockette::Viewer.new
        viewer.launch!
      when 2
        puts "Deploy"
      when 3
        exporter = Rockette::Exporter.new
        exporter.launch!
      when 4
        Rockette::Configurator.new.configure
      else
        puts "\nI don't understand that command.\n\n"
      end
    end
  end
end
