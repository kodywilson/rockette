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
        @conf = Psych.load(File.read(CONF))
        @body = @conf["token_body"]
        @hdrs = @conf["token_hdrs"]
        @hdrs["Authorization"] = @conf["web_creds"][@options[:cred]] if @options[:cred]
        @filey = "f#{@options[:app_id]}.sql"
        @token = get_token
        @hdrs["Authorization"] = "Bearer " + @token
      end

      def checker
        app_url = "#{@options[:url]}deploy/apps/#{@options[:app_id]}"
        response = Rester.new(url: app_url, headers: @hdrs).rest_try
        bail unless response
        abort padder("App ID: #{@options[:app_id]}, not found. Received: #{response.code}") unless response.code == 200
      end

      def exporter
        checker
        puts padder("Found Application ID: #{@options[:app_id]}, proceeding...")
        export_url = "#{@options[:url]}deploy/app/#{@options[:app_id]}"
        response = Rester.new(url: export_url, headers: @hdrs).rest_try
        bail unless response
        abort padder("Download failed for App ID: #{@options[:app_id]}.") unless (200..201).include? response.code
        response
      end

      def get_token
        token_url = "#{@options[:url]}oauth/token"
        response = Rester.new(headers: @hdrs, meth: "Post", params: @body, url: token_url).rest_try
        return JSON.parse(response.body)["access_token"]
      end

      def execute(input: $stdin, output: $stdout)
        check_input(input)
        response = exporter
        # Write file if export was grabbed.
        save_file = @options[:file] || @filey
        File.open(File.join(EXPORT_DIR, save_file), "wb") { |file| file.write(response.body) }
        output.puts padder("Finished downloading #{save_file}. Have a good one!")
      end
    end
  end
end
