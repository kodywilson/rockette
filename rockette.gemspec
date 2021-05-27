# frozen_string_literal: true

require_relative "lib/rockette/version"

Gem::Specification.new do |spec|
  spec.name          = "rockette"
  spec.version       = Rockette::VERSION
  spec.authors       = ["Kody Wilson"]
  spec.email         = ["kodywilson@gmail.com"]

  spec.summary       = "Oracle APEX Deployment Assistant"
  spec.description   = "Rockette helps deploy and export APEX applications."
  spec.homepage      = "https://github.com/kodywilson/rockette"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "https://github.com/kodywilson/rockette/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Dev dependencies
  spec.add_development_dependency "pry", "~> 0.0"

  # Dependencies
  spec.add_dependency "pastel", "~> 0.0"
  spec.add_dependency "rest-client", "~> 2.0"
  spec.add_dependency "thor", "~> 1.0"
  spec.add_dependency "tty-config", "~> 0.0"
  spec.add_dependency "tty-editor", "~> 0.0"
  spec.add_dependency "tty-font", "~> 0.0"
  spec.add_dependency "tty-prompt", "~> 0.0"
  spec.add_dependency "tty-spinner", "~> 0.0"
  spec.add_dependency "tty-table", "~> 0.0"
end
