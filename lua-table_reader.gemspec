# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lua/table_reader/version'

Gem::Specification.new do |spec|
  spec.name          = "lua-table_reader"
  spec.version       = Lua::TableReader::VERSION
  spec.authors       = ["Graham Haworth"]
  spec.email         = ["gdhaworth@gmail.com"]
  spec.summary       = "Quick and dirty Lua table reader"
  spec.description   = "A very quick and dirty tool to read Lua tables as native Ruby objects."
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  
  spec.add_runtime_dependency 'citrus', '~> 2.4.1'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
end
