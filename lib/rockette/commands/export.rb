# frozen_string_literal: true

require_relative "../command"

module Rockette
  module Commands
    # Export and download APEX application
    class Export < Rockette::Command
      include TextHelper

      def initialize(options)
        super()
        @options = options
        @filey = "f#{@options[:app_id]}.sql"
      end

      def checker
        app_url = "#{@options[:url]}deploy/apps/#{@options[:app_id]}"
        response = Rester.new(url: app_url).rest_try
        bail unless response
        abort padder("App ID: #{@options[:app_id]}, not found. Received: #{response.code}") unless response.code == 200
      end

      def exporter
        checker
        puts padder("Found Application ID: #{@options[:app_id]}, proceeding...")
        body = { "app_id" => @options[:app_id] }
        export_url = "#{@options[:url]}deploy/app_export"
        response = Rester.new(meth: "Post", params: body, url: export_url).rest_try
        bail unless response
        abort padder("Export failed for App ID: #{@options[:app_id]}.") unless (200..201).include? response.code
        response
      end

      def grabber
        export_url = "#{@options[:url]}deploy/app_export/#{@filey}"
        response = Rester.new(url: export_url).rest_try
        bail unless response
        abort padder("Download failed for App ID: #{@options[:app_id]}.") unless (200..201).include? response.code
        response
      end

      def execute(input: $stdin, output: $stdout)
        check_input(input)
        # Create and download export
        exporter
        output.puts padder("Export created, downloading...")
        sleep 1
        response = grabber
        # Write file if export was grabbed.
        save_file = @options[:file] || @filey
        File.open(File.join(EXPORT_DIR, save_file), "wb") { |file| file.write(response.body) }
        output.puts padder("Finished downloading #{save_file}. Have a good one!")
      end
    end
  end
end
