# frozen_string_literal: true

require_relative '../command'

module Rockette
  module Commands
    class Export < Rockette::Command
      def initialize(options)
        @options = options
      end

      def execute(input: $stdin, output: $stdout)
        # Create and download export
        app_url = @options[:url] + 'deploy/apps/' + @options[:app_id]
        check = Rester.new(url: app_url).rest_try
        unless check == nil
          if check.code == 200
            puts "Found application id: #{@options[:app_id]}, proceeding..."
          else
            puts "Could not find app id: #{@options[:app_id]}, expected: 200, but received: #{check.code}"
            exit 1
          end
        else
          puts "Bailing, unable to check for application. Can you access the url from here?"
          exit 1
        end
        output.puts "OK, exporting and downloading App ID: #{@options[:app_id]}"
        filey = "f#{@options[:app_id]}.sql"
        body = {
          "app_id" => @options[:app_id]
        }
        export_url = @options[:url] + 'deploy/app_export'
        export = Rester.new(meth: 'Post', params: body, url: export_url).rest_try
        if export.code == 201 # Check if export was successfully created first
          sleep 1 # Just try a couple of times if needed then bail on error
          export_url = export_url + '/' + filey
          snag_export = Rester.new(headers: {}, meth: 'Get', params: {}, url: export_url).rest_try
          # Now write file if export was grabbed.
          if snag_export.code == 200 || snag_export.code == 201
            File.open(filey, 'wb') {|file| file.write(snag_export.body)}
            puts "Downloaded #{filey} and all done here."
          else
            puts "Download failed for #{filey}!"
          end
        else
          puts "Unable to create application export for App ID: #{@options[:app_id]}!"
          # puts more error info here, like code at least.
        end
      end
    end
  end
end
