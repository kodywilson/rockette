# frozen_string_literal: true

require_relative '../command'

module Rockette
  module Commands
    class Deploy < Rockette::Command
      def initialize(options)
        @options = options
      end

       # Import application export into APEX instance
      def import_app(url, body)
        response = RestClient.post url, body
      rescue StandardError => e
        puts "Unable to import application because #{e.message}" # puts error
      end

      # Push attachment to api endpoint and show code
      def push_blob(filey, headers, url)
        response = RestClient.post url, filey, headers
        response
      rescue StandardError => e
        puts "Unable to push file because #{e.message}" # puts error
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
        #pusher = push_blob(File.open(filey), push_hdrs, push_url)
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
            #deploy = import_app(@options[:url] + 'deploy/app', body)
            unless deploy == nil
              puts deploy.code
              puts deploy.headers
              puts deploy.body
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
