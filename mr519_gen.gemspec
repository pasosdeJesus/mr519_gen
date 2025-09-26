# frozen_string_literal: true

$:.push(File.expand_path("lib", __dir__))

# Maintain your gem's version:
require "mr519_gen/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "mr519_gen"
  s.version     = Mr519Gen::VERSION
  s.authors     = ["Vladimir Tamara"]
  s.email       = ["vtamara@pasosdejesus.org"]
  s.homepage    = "https://gitlab.com/pasosdeJesus/mr519_gen"
  s.summary     = "Formularios"
  s.description = "Formularios"
  s.license     = "ISC"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENCIA", "Rakefile", "README.md"]

  s.add_dependency("msip")
  s.add_dependency("rails")

  s.add_development_dependency("pg")
end
