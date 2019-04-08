$LOAD_PATH.push File.expand_path("../lib", __FILE__)

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
  gem.description = "Content and Subscription Management plugin for Foreman"

  gem.files = Dir["{app,webpack,vendor,lib,db,ca,config,locale}/**/*"] +
    ['LICENSE.txt', 'README.md', 'package.json']
  gem.files += Dir["engines/bastion_katello/{app,vendor,lib,config}/**/*"]
  gem.files += Dir["engines/bastion_katello/{README.md}"]
  gem.files -= ["lib/katello/tasks/annotate_scenarios.rake"]

  gem.require_paths = ["lib"]

  # Core Dependencies
  gem.add_dependency "rails"
  gem.add_dependency "json"
  gem.add_dependency "oauth"
  gem.add_dependency "rest-client"

  gem.add_dependency "rabl"
  gem.add_dependency "foreman-tasks", "~> 0.13", ">= 0.14.1"
  gem.add_dependency "foreman_docker", "< 4.1.1", ">= 0.2.0"

  gem.add_dependency "qpid_messaging"
  gem.add_dependency "gettext_i18n_rails"
  gem.add_dependency "apipie-rails", ">= 0.5.14"

  # Pulp
  gem.add_dependency "runcible", ">= 2.10.0", "< 2.11.0"
  gem.add_dependency "anemone"

  # UI
  gem.add_dependency "deface", '>= 1.0.2', '< 2.0.0'
  gem.add_dependency "bastion", ">= 6.1.13", "< 7.0.0"

  # Testing
  gem.add_development_dependency "factory_bot_rails", "~> 4.5"
  gem.add_development_dependency "minitest-tags"
  gem.add_development_dependency "mocha"
  gem.add_development_dependency "vcr", "< 4.0.0"
  gem.add_development_dependency "webmock"
  gem.add_development_dependency "rubocop-checkstyle_formatter"
  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "simplecov-rcov"
  gem.add_development_dependency "robottelo_reporter"
end
