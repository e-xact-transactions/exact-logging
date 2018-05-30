# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'exact/logging'

Gem::Specification.new do |spec|
  spec.name          = "exact-logging"
  spec.version       = Exact::Logging::VERSION
  spec.authors       = ["Donncha Redmond"]
  spec.email         = ["github@mail.donncha.com"]
  spec.description   = %q{Simple logging for gem development.}
  spec.summary       = %q{Simple logging which logs to a file if Rails.logger is not defined.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = Dir["{lib}/**/*"] + ["Rakefile", "README.md"]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
