$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "katello/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "katello"
  s.version     = Katello::VERSION
  s.authors     = ["N/A"]
  s.email       = ["N/A"]
  s.homepage    = "http://www.katello.org"
  s.summary     = ""
  s.description = ""

  s.files = Dir["{app,vendor,lib,config}/**/*"] + ["LICENSE.txt", "Rakefile", "README.md"]
end
