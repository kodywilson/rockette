# frozen_string_literal: true

require           'json'
require           'rest-client'
require           'thor'
require_relative  'rockette/cli'
require_relative  'rockette/version'

module Rockette
  class Error < StandardError; end

  class Rester

    VERBS = {
      'delete' => :Delete,
      'get'    => :Get,
      'post'   => :Post,
      'put'    => :Put
    }
  
    def initialize(headers: {}, meth: 'Get', params: {}, url: 'https://array/')
      @headers = headers
      @meth    = meth
      @params  = params
      @url     = url
    end
  
    def make_call
      #@params = @params.to_json unless @meth.downcase == 'get' || @meth.downcase == 'delete'
      begin
        response = RestClient::Request.execute(headers: @headers,
                                               method: VERBS[@meth.downcase],
                                               payload: @params,
                                               timeout: 30,
                                               url: @url,
                                               verify_ssl: false)
      rescue => e
        e.response
      else
        response
      end
    end
  
    def cookie
      if @url =~ /auth\/session/
        response = make_call
        raise 'There was an issue getting a cookie!' unless response.code == 200
        cookie = (response.cookies.map{|key,val| key + '=' + val})[0]
      else
        error_text("cookie", @url.to_s, 'auth/session')
      end
    end
  
    def error_text(method_name, url, wanted)
      response = {
        "response" =>
          "ERROR: Wrong url for the #{method_name} method.\n"\
          "Sent: #{url}\n"\
          "Expected: \"#{wanted}\" as part of the url.",
        "status" => 400
      }
    end

    def responder(response)
      response = {
        "response" => JSON.parse(response.body),
        "status" => response.code.to_i
      }
    end

    # use rest-client with retry
    def rest_try
      3.times { |i|
        response = make_call
        break response if (200..299).include? response.code
        break response if i >= 2
        puts "Failed #{@meth} on #{@url}, retry...#{i + 1}"
        sleep 3
      }
    end
  
  end

end
