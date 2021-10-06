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
        @filey = @options[:file]
        if @options[:secret]
          secret_id = @options[:secret]
          signer = OCI::Auth::Signers::InstancePrincipalsSecurityTokenSigner.new
          identity_client = OCI::Identity::IdentityClient.new(config: OCI::Config.new, signer: signer)
          secret_client = OCI::Secrets::SecretsClient.new(config: OCI::Config.new, signer: signer)
          secret_response = secret_client.get_secret_bundle(secret_id).data.secret_bundle_content.content
          @conf = Psych.load(Base64.decode64(secret_response))
        else
          @conf = Psych.load(File.read(CONF))
        end
        @body = @conf["token_body"]
        @hdrs = @conf["token_hdrs"]
        @hdrs["Authorization"] = @conf["web_creds"][@options[:cred]] if @options[:cred]
        @token = get_token
        @hdrs["Authorization"] = "Bearer " + @token
      end

      def check_version(filey)
        app_url = "#{@options[:url]}deploy/apps/#{@options[:app_id]}"
        response = Rester.new(url: app_url, headers: @hdrs).rest_try
        bail unless response
        abort padder("App ID: #{@options[:app_id]}, not found. Received: #{response.code}") unless response.code == 200
        deployed_version = JSON.parse(response.body)["version"]
        fh = File.open(filey, 'r')
        export_version = ''
        fh.each_line do |line|
          if line.match(/,p_flow_version=>'/)
            export_version = line.match(/^,p_flow_version=>'(.*?)'$/)[1]
          end
        end
        return deployed_version == export_version
      end

      def file_finder
        [EXPORT_DIR, "/usr/app", "/usr/local/app"].each do |f|
          next unless File.exist?(File.join(f, @filey))
          break File.join(f, @filey) if File.exist?(File.join(f, @filey)) # Take 1st match
        end
      end

      def get_token
        token_url = "#{@options[:url]}oauth/token"
        response = Rester.new(headers: @hdrs, meth: "Post", params: @body, url: token_url).rest_try
        return JSON.parse(response.body)["access_token"]
      end

      def deployer
        push_url = "#{@options[:url]}deploy/app/#{@options[:app_id]}/"
        filey = file_finder
        file_not_found if filey.is_a?(Array)
        if @options[:app_id] != '0' then
          abort padder("Error. Versions are identical, unable to deploy export") if check_version(filey)
        end
        @hdrs["Content-Type"] = "application/sql"
        response = Rester.new(headers: @hdrs, meth: "Post", params: File.open(filey), url: push_url).rest_try
        bail unless response
        abort padder("Error. Got back response code: #{response.code}") unless (200..201).include? response.code
        response
      end

      def execute(input: $stdin, output: $stdout)
        check_input(input)
        filey = file_finder
        file_not_found if filey.is_a?(Array)
        output.puts padder("Attempting to deploy export file #{@filey}...")
        deployer
        output.puts padder("Deployed #{@filey} to target APEX instance: #{@options[:url]}")
      end
    end
  end
end
