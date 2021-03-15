# frozen_string_literal: true

require_relative "../command"

module Rockette
  module Commands
    # Configure Rockette
    class Config < Rockette::Command
      include TextHelper

      def initialize(options)
        super()
        @options = options
      end

      def execute(input: $stdin, output: $stdout)
        # Command logic goes here ...
        output.puts "Coming soon..."
        check_input(input)
      end
    end
  end
end
