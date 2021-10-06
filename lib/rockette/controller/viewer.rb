# frozen_string_literal: true

require_relative "../text_helper"

module Rockette
  # View resources
  class Viewer
    include TextHelper

    def initialize
      @config = TTY::Config.new
      @config.append_path APP_PATH
      @config.read
      @conf = Psych.load(File.read(CONF))
      @body = @conf["token_body"]
      @hdrs = @conf["token_hdrs"]
      #@hdrs["Authorization"] = @conf["web_creds"]["controller_cred"]
      token_url = @conf["rockette"]["controller_url"].sub!('deploy/', '')
      @token = get_token(token_url, "controller_cred")
      @hdrs["Authorization"] = "Bearer " + @token
      @pastel = Pastel.new
      @prompt = TTY::Prompt.new
      @spinner = TTY::Spinner.new # ("[:spinner] Loading APEX environments ...", format: pulse_2)
      @view_actions = { "🏔  APEX Environments" => 1, "🎭 Registered Applications" => 2,
                        "🌎 Applications by Environment" => 3, "⬅️  Go Back" => 4 }
    end

    def self.config
      @config ||= self.class.new.config
    end

    def launch!
      puts padder("You can view environments or registered applications")
      puts

      # input/action loop
      loop do
        action = @prompt.select("Which would you like to see?", @view_actions)
        break if action == 4

        do_action(action)
      end
    end

    def do_action(action)
      case action
      when 1
        puts
        environments unless @table_env
        spinner(0.5)
        puts @table_env.render(:unicode, resize: true, border: { style: :yellow })
        puts
      when 2
        puts
        registered unless @table_reg
        puts @table_reg.render(:unicode, resize: true, border: { style: :yellow })
        puts
      when 3
        puts
        puts "This can take a while...hang tight!"
        puts
        all_apps unless @table_all_apps
        puts @table_all_apps.render(:unicode, resize: true, border: { style: :yellow })
        puts
      else
        puts "\nI don't understand that command.\n\n"
      end
    end

    def add_web_cred(env_cred, env_name)
      puts "You are attempting to access a resource that requires authentication."
      puts "Please enter the OAuth client credentials for the #{env_name} environment."
      user = @prompt.ask("User:")
      pass = @prompt.ask("Pass:")
      basey = 'Basic ' + Base64.encode64(user + ":" + pass).tr("\n", "")
      @config.set(:web_creds, env_cred.to_sym, value: basey)
      @config.write(force: true)
      refresh_conf
    end

    def ape_e_i(uri, headers = @hdrs)
      response = Rester.new(url: uri, headers: headers).rest_try
      bail unless response
      abort padder("#{uri} didn't work. Received: #{response.code}") unless response.code == 200
      response
    end

    def applications(url, cred)
      headers = @hdrs
      #@hdrs["Authorization"] = @conf["web_creds"][cred]
      @token = get_token(url, cred)
      @hdrs["Authorization"] = "Bearer " + @token
      uri = "#{url}deploy/apps/"

      response = ape_e_i(uri, @hdrs)
      @hdrs = headers
      JSON.parse(response.body)["items"]
    end

    def environments
      uri = "#{@conf["rockette"]["controller_url"]}deploy/environments/"
      response = ape_e_i(uri)
      @table_env = TTY::Table.new(header: ["Environment Name", "API", "Domain", "Owner", "Workspace", "Web Cred"])
      items = JSON.parse(response.body)["items"]
      items.each { |h| @table_env << [h["name"], h["deployment_api"], h["domain"], h["owner"], h["workspace"], h["web_cred"]] }
    end

    def get_token(url, cred)
      @hdrs["Authorization"] = @conf["web_creds"][cred]
      token_url = url + "oauth/token"
      response = Rester.new(headers: @hdrs, meth: "Post", params: @body, url: token_url).rest_try
      return JSON.parse(response.body)["access_token"]
    end

    def registered
      uri = "#{@conf["rockette"]["controller_url"]}deploy/registered_apps/"
      response = ape_e_i(uri)
      @table_reg = TTY::Table.new(header: ["Registered Name", "Source App ID", "Source URI", "Target App ID",
                                           "Target URI"])
      JSON.parse(response.body)["items"].each do |h|
        @table_reg << [h["registered_name"], h["src_app_id"], h["src_url"], h["tgt_app_id"], h["tgt_url"]]
      end
    end

    def all_apps
      environments unless @table_env
      @table_all_apps = TTY::Table.new(header: ["Environment Name", "Application Name", "Application ID"])
      @table_env.each do |env|
        next if env[0] == "Environment Name"

        creds = Hash.new
        creds = @conf["web_creds"]
        add_web_cred(env[5], env[0]) unless creds.has_key?(env[5])

        apps = applications(env[1], env[5])
        apps.each do |app|
          @table_all_apps << [env[0], app["application_name"], app["application_id"]]
        end
      end
    end

    def refresh_conf
      @config.read
      @conf = Psych.load(File.read(CONF))
    end

    def spinner(dur=1)
      @spinner.auto_spin
      sleep(dur)
      @spinner.stop
    end

  end
end
