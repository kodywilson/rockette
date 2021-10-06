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
    option :app_id, aliases: "-a", default: "0",
                    desc: "Update this App ID with export set by '-f' Omitting '-a' copies export to target"
    option :file, aliases: "-f", required: true,
                  desc: "Provide an APEX application export file (sql)"
    option :url, aliases: "-u", required: true,
                 desc: "Provide a valid APEX deployment url"
    option :secret, aliases: "-s", required: false,
                  desc: "Use this flag if you are using managed secrets"
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
    option :file, aliases: "-f", required: false,
                  desc: "Save export with this file name"

    def export(*)
      if options[:help]
        invoke :help, ["export"]
      else
        require_relative "commands/export"
        Rockette::Commands::Export.new(options).execute
      end
    end

    desc "config", "Set configuration options..."
    method_option :help, aliases: "-h", type: :boolean,
                         desc: "Not implemented yet..."
    def config(*)
      if options[:help]
        invoke :help, ["config"]
      else
        require_relative "commands/config"
        Rockette::Commands::Config.new(options).execute
      end
    end

    desc "interactive", "Start Rockette in interactive mode"
    method_option :help, aliases: "-h", type: :boolean,
                         desc: "'rockette' by itself will start interactive mode"
    def interactive(*)
      if options[:help]
        invoke :help, ["interactive"]
      else
        require_relative "commands/interactive"
        Rockette::Commands::Interactive.new(options).execute
      end
    end

    default_task :interactive
  end
end
