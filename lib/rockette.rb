# frozen_string_literal: true

require           "erb"
require           "json"
require           "pastel"
require           "psych"
require           "rest-client"
require           "thor"
require           "tty-config"
require           "tty-font"
require           "tty-prompt"
require_relative  "rockette/cli"
require_relative  "rockette/controller"
require_relative  "rockette/text_helper"
require_relative  "rockette/version"

# APEX deployment
module Rockette
  class Error < StandardError; end

  # rest-client calls with error handling and auto retries
  class Rester
    VERBS = {
      "delete" => :Delete,
      "get" => :Get,
      "post" => :Post,
      "put" => :Put
    }.freeze

    def initialize(headers: {}, meth: "Get", params: {}, url: "https://array/", config: {})
      @headers = headers
      @meth    = meth
      @params  = params
      @url     = url
      @config = config
      @config["timeout"] = @config["timeout"] ||= 30
    end

    def make_call
      response = RestClient::Request.execute(headers: @headers,
                                             method: VERBS[@meth.downcase], payload: @params,
                                             timeout: @config["timeout"], url: @url, verify_ssl: false)
    rescue SocketError, IOError => e
      puts "#{e.class}: #{e.message}"
      nil
    rescue StandardError => e
      e.response
    else
      response
    end

    def cookie
      if @url =~ %r{auth/session}
        response = make_call
        raise "There was an issue getting a cookie!" unless response.code == 200

        (response.cookies.map { |key, val| "#{key}=#{val}" })[0]
      else
        error_text("cookie", @url.to_s, "auth/session")
      end
    end

    # use rest-client with retry
    def rest_try(tries = 3)
      tries.times do |i|
        response = make_call
        unless response.nil?
          break response if (200..299).include? response.code
          break response if i > 1
        end
        puts "Failed #{@meth} on #{@url}, retry...#{i + 1}"
        sleep 3 unless i > 1
        return nil if i > 1 # Handles socket errors, etc. where there is no response.
      end
    end

    private

    def error_text(method_name, url, wanted)
      {
        "response" =>
          "ERROR: Wrong url for the #{method_name} method.\n"\
          "Sent: #{url}\n"\
          "Expected: \"#{wanted}\" as part of the url.",
        "status" => 400
      }
    end

    def responder(response)
      {
        "response" => JSON.parse(response.body),
        "status" => response.code.to_i
      }
    end
  end
end
