# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "sarif/gem_version"

Gem::Specification.new do |spec|
  spec.name          = "danger-sarif"
  spec.version       = Sarif::VERSION
  spec.authors       = ["irgaly"]
  spec.email         = ["irgaly@gmail.com"]
  spec.description   = "Danger plugin for reporting SARIF file."
  spec.summary       = "Danger plugin for reporting SARIF file."
  spec.homepage      = "https://github.com/irgaly/danger-sarif"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "danger-plugin-api", ">= 1.0"
  spec.add_development_dependency "bundler", ">= 2.0"
  spec.add_development_dependency "rake", ">= 10.0"
  spec.add_development_dependency "rspec", ">= 3.4"
  spec.add_development_dependency "faraday-retry", ">= 2.2.0"
  spec.add_development_dependency "yard", ">= 0.9.34"
end
