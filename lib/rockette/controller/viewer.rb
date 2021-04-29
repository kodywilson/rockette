# frozen_string_literal: true

require_relative "../text_helper"

module Rockette
  # View resources
  class Viewer
    include TextHelper

    def initialize
      @conf = Psych.load(File.read(CONF))
      @pastel = Pastel.new
      @prompt = TTY::Prompt.new
      @spinner = TTY::Spinner.new # ("[:spinner] Loading APEX environments ...", format: pulse_2)
      @view_actions = { "🏔  APEX Environments" => 1, "🎭 Registered Applications" => 2, "⬅️  Go Back" => 3 }
    end

    def launch!
      puts padder("You can view environments or registered applications")
      puts

      # input/action loop
      loop do
        action = @prompt.select("Which would you like to see?", @view_actions)
        break if action == 3

        do_action(action)
      end
    end

    def do_action(action)
      case action
      when 1
        puts
        environments unless @table_env
        @spinner.auto_spin
        sleep(1)
        @spinner.stop
        puts @table_env.render(:unicode, resize: true, border: { style: :yellow })
        puts
      when 2
        puts
        registered unless @table_reg
        puts @table_reg.render(:unicode, resize: true, border: { style: :yellow })
        puts
      else
        puts "\nI don't understand that command.\n\n"
      end
    end

    def ape_e_i(uri)
      response = Rester.new(url: uri).rest_try
      bail unless response
      abort padder("#{uri} didn't work. Received: #{response.code}") unless response.code == 200
      response
    end

    def applications(url)
      uri = "#{url}deploy/apps"
      response = ape_e_i(uri)
      JSON.parse(response.body)["items"]
    end

    def environments
      uri = "#{@conf["rockette"]["controller_url"]}deploy/environments/"
      response = ape_e_i(uri)
      @table_env = TTY::Table.new(header: ["Environment Name", "API", "Domain", "Owner", "Workspace"])
      items = JSON.parse(response.body)["items"]
      items.each { |h| @table_env << [h["name"], h["deployment_api"], h["domain"], h["owner"], h["workspace"]] }
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
  end
end
