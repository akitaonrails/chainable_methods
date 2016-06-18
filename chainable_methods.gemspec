# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chainable_methods/version'

Gem::Specification.new do |spec|
  spec.name          = "chainable_methods"
  spec.version       = ChainableMethods::VERSION
  spec.authors       = ["AkitaOnRails"]
  spec.email         = ["fabioakita@gmail.com"]

  spec.summary       = %q{Just a simple experiment to allow for a behavior similar to [Elixir|Haskell|F#]'s Pipe Operator but within Ruby's semantics.}
  spec.description   = %q{The idea is to allow for a more functional way of organizing code within a module and being able to chain those methdos together, where the result of the first method serves as the first argument of the next method in the chain.}
  spec.homepage      = "http://www.codeminer42.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "pry", "~> 0.10.3"
  spec.add_development_dependency 'nokogiri', '~> 1.6', '>= 1.6.8'
  spec.add_development_dependency 'vcr', '~> 3.0', '>= 3.0.3'
  spec.add_development_dependency 'webmock', '~> 2.1', '>= 2.1.0'
end
