# frozen_string_literal: true

require_relative '../command'

module Rockette
  module Commands
    class Deploy < Rockette::Command
      def initialize(options)
        @options = options
      end

      def execute(input: $stdin, output: $stdout)
        # Create and download export
        output.puts "OK, deploying export file #{@options[:file]}"
        filey = "f#{@options[:app_id]}.sql"
        # First push the chosen export file to the target system.
        push_hdrs = CONF["push_hdrs"]
        push_hdrs["file_name"] = filey
        push_url = @options[:url] + 'data_loader/blob'
        pusher = Rester.new(headers: push_hdrs, meth: 'Post', params: File.open(filey), url: push_url).rest_try
        # If push was successful, request application import
        unless pusher == nil
          if pusher.code == 200 || pusher.code == 201
            sleep 1 # replace with check for file on server
            puts "Pushed #{filey} and attempting import now..."
            body = CONF["deploy_body"]
            body["app_id_src"] = @options[:app_id]
            body["app_id_tgt"] = @options[:app_id]
            #body["app_id_tgt"] = "0" #test app copy
            url = @options[:url] + 'deploy/app'
            deploy = Rester.new(meth: 'Post', params: body, url: url).rest_try
            unless deploy == nil
              if deploy.code == 200
                puts
                puts "Successfully deployed file: #{filey} to target app id: #{@options[:app_id]}"
                puts
              end
            else
              bail_text
              exit 1
            end
          end
        else
          bail_text
          exit 1
        end
      end
    end
  end
end
