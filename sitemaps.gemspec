# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sitemaps/version'

Gem::Specification.new do |spec|
  spec.name          = "sitemaps_parser"
  spec.version       = Sitemaps::VERSION
  spec.authors       = ["Jonathan Raphaelson"]
  spec.email         = ["jraphaelson@termscout.com"]

  spec.summary       = "Retrieve and parse sitemaps, according to the sitemaps.org spec."
  spec.homepage      = "http://github.com/termscout/sitemaps"
  spec.license       = "MIT"

  files = `git ls-files -z`.split("\x0")
  files.reject! { |f| f.match(%r{^(test|spec|features)/}) }

  spec.files         = files
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 12.3"
  spec.add_development_dependency "rspec", "~> 3.8"
  spec.add_development_dependency "webmock", "~> 3.4"
  spec.add_development_dependency "vcr", "~> 4"
  spec.add_development_dependency "rubocop", "~> 0.59.1"
  spec.add_development_dependency "byebug", "~> 10.0"
  spec.add_development_dependency "yard", "~> 0.9"

  spec.add_runtime_dependency "activesupport", "~> 5.2"
end
