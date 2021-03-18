# frozen_string_literal: true

module Rockette
  #
  # @api public
  # Handle actions and parameters
  class CLI < Thor
    # Error raised by this runner
    Error = Class.new(StandardError)

    desc "version", "rockette version"
    def version
      require_relative "version"
      puts "v#{Rockette::VERSION}"
    end
    map %w[--version -v] => :version

    desc "deploy", "Deploy chosen export file to target APEX instance"
    method_option :help, aliases: "-h", type: :boolean,
                         desc: "Display usage information"
    option :app_id, aliases: "-a", required: true,
                    desc: "Provide an APEX application ID"
    option :file, aliases: "-f", required: true,
                  desc: "Provide an APEX application export file (.sql)"
    option :url, aliases: "-u", required: true,
                 desc: "Provide a valid APEX deployment url"
    option :copy, aliases: "-c", required: false,
                  desc: "Use this flag if you are copying an application instead of overwriting"
    def deploy(*)
      if options[:help]
        invoke :help, ["deploy"]
      else
        require_relative "commands/deploy"
        Rockette::Commands::Deploy.new(options).execute
      end
    end

    desc "export", "Export and download application from target APEX environment"
    method_option :help, aliases: "-h", type: :boolean,
                         desc: "Display usage information"
    option :app_id, aliases: "-a", required: true,
                    desc: "Provide an APEX application ID"
    option :url, aliases: "-u", required: true,
                 desc: "Provide a valid url"
    def export(*)
      if options[:help]
        invoke :help, ["export"]
      else
        require_relative "commands/export"
        Rockette::Commands::Export.new(options).execute
      end
    end

    desc "config", "Command description..."
    method_option :help, aliases: "-h", type: :boolean,
                         desc: "Display usage information"
    def config(*)
      if options[:help]
        invoke :help, ["config"]
      else
        require_relative "commands/config"
        Rockette::Commands::Config.new(options).execute
      end
    end
  end
end
