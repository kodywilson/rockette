# frozen_string_literal: true

require_relative "rockette/version"

module Rockette
  class Error < StandardError; end
  # 
  # # Export application on APEX instance
  # def create_export(body, url)
  #   response = RestClient.post url, body
  #   response
  # rescue StandardError => e
  #   # change these, send back the error message, don't puts it!
  #   puts "Unable to create export because #{e.message}" # puts error
  # end

  # # Grab application export from APEX instance
  # def grab_export(url)
  #   response = RestClient.get url
  # rescue StandardError => e
  #   puts "Unable to grab export because #{e.message}" # puts error
  # end

  # # Import application export into APEX instance
  # def import_app(url, body)
  #   response = RestClient.post url, body
  # rescue StandardError => e
  #   puts "Unable to import application because #{e.message}" # puts error
  # end

  # # Push attachment to api endpoint and show code
  # def push_blob(filey, headers, url)
  #   response = RestClient.post url, filey, headers
  #   response
  # rescue StandardError => e
  #   puts "Unable to push file because #{e.message}" # puts error
  # end

end
