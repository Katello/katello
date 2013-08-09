$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "bastion/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "bastion"
  s.version     = Bastion::VERSION
  s.authors     = [""]
  s.email       = [""]
  s.homepage    = "http://www.katello.org"
  s.summary     = "Summary of Bastion."
  s.description = "Description of Bastion."

  s.files = Dir["{app,config,lib}/**/*"] + ["README"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.8"
  s.add_dependency "ui_alchemy-rails"
end
