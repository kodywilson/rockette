# frozen_string_literal: true

require_relative "../command"

module Rockette
  module Commands
    # Interactive Rockette
    class Interactive < Rockette::Command
      include TextHelper

      def initialize(options)
        super()
        @options = options
      end

      def execute(input: $stdin, output: $stdout)
        output.puts
        check_input(input)
        controller = Rockette::Controller.new
        controller.launch!
      end
    end
  end
end
