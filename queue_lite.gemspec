# frozen_string_literal: true

require_relative "lib/queue_lite/version"

Gem::Specification.new do |spec|
  spec.name = "queue_lite"
  spec.version = QueueLite::VERSION
  spec.authors = ["Adam Daniels"]
  spec.email = ["adam@mediadrive.ca"]

  spec.summary = "Simple queue implementation on top of SQLite"
  spec.homepage = "https://github.com/adam12/queue_lite"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "sqlite3"
end
