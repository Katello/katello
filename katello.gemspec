$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "katello/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |gem|
  gem.name        = "katello"
  gem.version     = Katello::VERSION
  gem.authors     = ["N/A"]
  gem.email       = ["katello-devel@redhat.com"]
  gem.homepage    = "http://www.katello.org"
  gem.summary     = ""
  gem.description = ""

  gem.files = Dir["{app,vendor,lib,db,config}/**/*"] + ["LICENSE.txt", "Rakefile", "README.md"]
  gem.require_paths = ["lib"]

  # Core Dependencies
  gem.add_dependency "rails"
  gem.add_dependency "json"
  gem.add_dependency "oauth"
  gem.add_dependency "rack-openid"
  gem.add_dependency "rest-client"

  gem.add_dependency "rails_warden", ">= 0.5.2"
  gem.add_dependency "warden"
  gem.add_dependency "net-ldap"
  gem.add_dependency "ldap_fluff", ">= 0.2.2"
  gem.add_dependency "foreigner"
  gem.add_dependency "daemons", ">= 1.1.4"
  gem.add_dependency "uuidtools"
  gem.add_dependency "rabl"
  gem.add_dependency "tire"
  gem.add_dependency "logging", ">= 1.8.0"
  gem.add_dependency "gettext_i18n_rails"
  gem.add_dependency "hooks"
  gem.add_dependency "logger"
  gem.add_dependency "dynflow"
  gem.add_dependency "justified"

  gem.add_dependency "delayed_job", "~> 3.0.2"
  gem.add_dependency "delayed_job_active_record", "~> 0.3.3"

  gem.add_dependency "i18n_data", ">= 0.2.6"

  # Documentation
  gem.add_dependency "apipie-rails", ">= 0.0.13"
  gem.add_dependency "maruku"

  # Reporting
  gem.add_dependency "acts_as_reportable", ">=1.1.1"
    
  # Pulp
  gem.add_dependency "runcible", "0.4.11"
  gem.add_dependency "anemone"

  # UI
  gem.add_dependency "simple-navigation", ">= 3.3.4"
  gem.add_dependency "sass-rails"
  gem.add_dependency "compass-rails"
  gem.add_dependency "compass-960-plugin"
  gem.add_dependency "haml-rails"
  gem.add_dependency "ui_alchemy-rails"
  gem.add_dependency "deface"

  # Development
  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "rspec-rails", "~> 2.13.2"
  gem.add_development_dependency "yard", ">= 0.5.3"
  gem.add_development_dependency "yard-activerecord"
  gem.add_development_dependency "js-routes", "~> 0.9.0"
  gem.add_development_dependency "gettext", ">= 1.9.3"
  gem.add_development_dependency "ruby_parser"
  gem.add_development_dependency "sexp_processor"
  gem.add_development_dependency "minitest-rails"
  gem.add_development_dependency "factory_girl_rails", "~> 1.4.0"
end
