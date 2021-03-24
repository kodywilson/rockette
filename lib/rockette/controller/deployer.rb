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
        response = @prompt.yes?("Would you like to create a copy of the application on the target system?")
        break unless response
       
      end
    end

  

    protected

    def intro_text
      puts
      puts @pastel.yellow("These are the two available options:")
      print "1. Copy application to an APEX instance. "
      print "It's " + @pastel.green.bold("generally safe and creates a new application") + " from the export\n"
      print "2. Update an existing application with your chosen export. "
      print @pastel.red.bold("Tread carefully") + " with this option!\n"
      puts
    end

    
  end
end
