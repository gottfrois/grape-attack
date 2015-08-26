# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'grape/attack/version'

Gem::Specification.new do |spec|
  spec.name          = "grape-attack"
  spec.version       = Grape::Attack::VERSION
  spec.authors       = ["Pierre-Louis Gottfrois"]
  spec.email         = ["pierrelouis.gottfrois@gmail.com"]

  spec.summary       = %q{A middleware for Grape to add endpoint-specific throttling.}
  spec.description   = %q{A middleware for Grape to add endpoint-specific throttling.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "grape", ">= 0.10"
  spec.add_dependency "redis-namespace"
  spec.add_dependency "activemodel", ">= 4.0"
  spec.add_dependency "activesupport", ">= 4.0"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
