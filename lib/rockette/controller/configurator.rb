
module Rockette
  class Configurator

      # attr_reader :files

      # def self.dirname
      #     @@dirname
      # end

      def initialize
        @conf = Psych.load(File.read(CONF))
      end

      def configure
          puts "This is a place holder:"
          puts "Please enter a number."
          choice = gets.chomp
          puts "You chose #{choice}."
      end

      def refresh_conf
        @conf = Psych.load(File.read(CONF))
      end

  end
end