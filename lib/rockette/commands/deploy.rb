# frozen_string_literal: true

require_relative "../command"

module Rockette
  module Commands
    # Push export file and import into APEX
    class Deploy < Rockette::Command
      include TextHelper

      def initialize(options)
        super()
        @options = options
        @filey = "f#{@options[:app_id]}.sql"
      end

      def importer
        body = CONF["deploy_body"]
        body["app_id_src"] = @options[:app_id]
        body["app_id_tgt"] = @options[:app_id]
        # body["app_id_tgt"] = "0" #test app copy
        url = "#{@options[:url]}deploy/app"
        response = Rester.new(meth: "Post", params: body, url: url).rest_try
        bail unless response
        abort padder("Error. Got back response code: #{response.code}") unless (200..201).include? response.code
        response
      end

      def pusher
        push_hdrs = CONF["push_hdrs"]
        push_hdrs["file_name"] = @filey
        push_url = "#{@options[:url]}data_loader/blob"
        # Push the chosen export file to the target system
        response = Rester.new(headers: push_hdrs, meth: "Post", params: File.open(@filey), url: push_url).rest_try
        bail unless response
        abort padder("Error. Got back response code: #{response.code}") unless (200..201).include? response.code
        response
      end

      def execute(input: $stdin, output: $stdout)
        check_input(input)
        # Create and download export
        output.puts padder("OK, deploying export file #{@filey}")
        pusher
        output.puts padder("Pushed #{@filey} to instance and attempting import now...")
        # If push was successful, request application import
        sleep 1
        importer
        output.puts padder("Deployed and imported #{@filey} to target APEX instance")
      end
    end
  end
end
