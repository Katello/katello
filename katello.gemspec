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

  gem.files = Dir["{app,vendor,lib,db,ca,config,locale}/**/*"] + ["LICENSE.txt", "README.md"]
  gem.files += Dir["engines/bastion/{app,vendor,lib}/**/*"]
  gem.files += Dir["engines/bastion/{README.md,Bastion.gemspec}"]
  gem.files += Dir["engines/fort/{app,config,db,lib}/**/*"]
  gem.files += Dir["engines/bastion/{README.md,fort.gemspec}"]

  gem.require_paths = ["lib"]

  # Core Dependencies
  gem.add_dependency "rails"
  gem.add_dependency "json"
  gem.add_dependency "oauth"
  gem.add_dependency "rest-client"
  gem.add_dependency "ruby-openid"

  gem.add_dependency "net-ldap"
  gem.add_dependency "ldap_fluff", ">= 0.2.2"
  gem.add_dependency "foreigner", "~> 1.4.2"
  gem.add_dependency "daemons", ">= 1.1.4"
  gem.add_dependency "uuidtools"
  gem.add_dependency "rabl"
  gem.add_dependency "tire", "~> 0.6.2"
  gem.add_dependency "logging", ">= 1.8.0"
  gem.add_dependency "hooks"
  gem.add_dependency "dynflow", "~> 0.1.0"
  gem.add_dependency "justified"
  gem.add_dependency "strong_parameters", "~> 0.2.1" # remove after we upgrade to Rails 4

  gem.add_dependency "delayed_job", "~> 3.0.2"
  gem.add_dependency "delayed_job_active_record", "~> 0.3.3"

  gem.add_dependency "gettext_i18n_rails"
  gem.add_dependency "i18n_data", ">= 0.2.6"

  # Documentation
  gem.add_dependency "apipie-rails", ">= 0.0.13"
  gem.add_dependency "maruku"

  # Pulp
  gem.add_dependency "runcible", "1.0.8"
  gem.add_dependency "anemone"

  # UI
  gem.add_dependency "angular-rails-templates", ">= 0.0.4"
  gem.add_dependency "simple-navigation", ">= 3.3.4"
  gem.add_dependency "less-rails"
  gem.add_dependency "sass-rails"
  gem.add_development_dependency "compass-rails"
  gem.add_development_dependency "compass-960-plugin"
  gem.add_dependency "haml-rails"
  gem.add_dependency "ui_alchemy-rails", '1.0.12'
  gem.add_dependency "deface"

  # Testing
  gem.add_development_dependency "rubocop", "0.17.0"
  gem.add_development_dependency "factory_girl_rails", "~> 1.4.0"
  gem.add_development_dependency "minitest-tags"
  gem.add_development_dependency "mocha", "~> 0.14.0"
  gem.add_development_dependency "vcr"
  gem.add_development_dependency "webmock"
  gem.add_development_dependency "rubocop-checkstyle_formatter"

end
