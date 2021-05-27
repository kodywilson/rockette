# frozen_string_literal: true

require_relative "requirements"

# Set paths
APP_PATH = if File.exist?(File.join("/", "usr", "app"))
             File.join("/", "usr", "app", ".rockette")
           elsif File.exist?(Dir.home)
             File.join(Dir.home, ".rockette")
           else
             no_rockette_dir
           end
lib_path = File.expand_path("../lib", __dir__)
tem_path = File.expand_path("../templates", __dir__)
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)

# Create directories and config file if needed
Dir.mkdir(APP_PATH) unless File.exist?(APP_PATH)
unless File.exist?(File.join(APP_PATH, "config.yml"))
  template = File.read(File.join(tem_path, "config.yml.erb"))
  data = ERB.new(template).result(binding)
  File.write(File.join(APP_PATH, "config.yml"), data)
end
Dir.mkdir(File.join(APP_PATH, "exports")) unless File.exist?(File.join(APP_PATH, "exports"))

# Set config and export directory paths
CONF = File.join(APP_PATH, "config.yml")
ENV["THOR_SILENCE_DEPRECATION"] = "true"
EXPORT_DIR = File.join(APP_PATH, "exports")

# APEX deployment
module Rockette
  class Error < StandardError; end
  # Code in lib/rockette
end
