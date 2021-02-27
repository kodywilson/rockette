# frozen_string_literal: true

require_relative '../command'

module Rockette
  module Commands
    class Export < Rockette::Command
      def initialize(options)
        @options = options
      end

      # Export application on APEX instance
      def create_export(body, url)
        response = RestClient.post url, body
        response
      rescue StandardError => e
        # change these, send back the error message, don't puts it!
        puts "Unable to create export because #{e.message}" # puts error
      end

      # Grab application export from APEX instance
      def grab_export(url)
        response = RestClient.get url
      rescue StandardError => e
        puts "Unable to grab export because #{e.message}" # puts error
      end

      def execute(input: $stdin, output: $stdout)
        # Create and download export
        output.puts "OK, exporting App ID: #{@options[:app_id]}"
        filey = "f#{@options[:app_id]}.sql"
        body = {
          "app_id" => @options[:app_id]
        }
        export_url = @options[:url] + 'deploy/app_export'
        puts export_url
        export = create_export(body, export_url)
        if export.code == 201 # Check if export was successfully created first
          sleep 1 # Change to query api to see if file is there
          export_url = export_url + '/' + filey
          response = grab_export(export_url)
          # Now write file if export was grabbed.
          if response.code == 200 || response.code == 201
            File.open(filey, 'wb') {|file| file.write(response.body)}
            puts "Downloaded #{filey} and all done here."
          end
        end
      end
    end
  end
end
