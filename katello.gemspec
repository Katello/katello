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

  s.files = Dir["{app,vendor,lib,db}/**/*"] + ["LICENSE.txt", "Rakefile", "README.md"]
  s.require_paths = ["lib"]

  # Documentation
  s.add_dependency "apipie-rails", ">= 0.0.13"
  s.add_dependency "maruku"

  s.add_dependency "rabl"
  s.add_dependency "simple-navigation", ">= 3.3.4"
  s.add_dependency "tire", ">= 0.3.0", "< 0.4"
  s.add_dependency "logging", ">= 1.8.0"
  s.add_dependency "oauth"
  s.add_dependency "rack-openid"
  s.add_dependency "rails_warden", ">= 0.5.2"
  s.add_dependency "rails_warden", ">= 0.5.2"
  s.add_dependency "gettext_i18n_rails"
  s.add_dependency "hooks"
  s.add_dependency "haml-rails"
  s.add_dependency "ui_alchemy-rails", "1.0.9"
  s.add_dependency "logger"

  # Reporting
  s.add_dependency "acts_as_reportable", ">=1.1.1"
    
  # Pulp
  s.add_dependency "runcible", "~> 0.4.7"

  # UI
  s.add_dependency "ui_alchemy-rails"

  # Development
  s.add_development_dependency "simplecov"
end
