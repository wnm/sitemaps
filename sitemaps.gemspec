# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sitemaps/version'

Gem::Specification.new do |spec|
  spec.name          = "sitemaps"
  spec.version       = Sitemaps::VERSION
  spec.authors       = ["Jonathan Raphaelson"]
  spec.email         = ["jon@accidental.cc"]

  spec.summary       = %q{Retrieve and parse sitemaps, according to the sitemaps.org spec.}
  spec.homepage      = "http://github.com/lygaret/sitemaps"
  spec.license       = "MIT"

  files = `git ls-files -z`.split("\x0")
  files.reject { |f| f.match(%r{^(test|spec|features)/}) }

  spec.files         = files
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
