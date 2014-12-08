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

  gem.files = Dir["{app,vendor,lib,db,ca,config,locale}/**/*"] + ["LICENSE.txt", "README.md"]
  gem.files += Dir["engines/bastion_katello/{app,vendor,lib,config}/**/*"]
  gem.files += Dir["engines/bastion_katello/{README.md,bastion_katello.gemspec}"]

  gem.require_paths = ["lib"]

  # Core Dependencies
  gem.add_dependency "rails"
  gem.add_dependency "json"
  gem.add_dependency "oauth"
  gem.add_dependency "rest-client"

  gem.add_dependency "uuidtools"
  gem.add_dependency "rabl"
  gem.add_dependency "tire", "~> 0.6.2"
  gem.add_dependency "logging", ">= 1.8.0"
  gem.add_dependency "hooks"
  gem.add_dependency "foreman-tasks", "~> 0.6.0"
  gem.add_dependency "foreman_docker", ">= 0.2.0"
  gem.add_dependency "justified"
  gem.add_dependency "strong_parameters", "~> 0.2.1" # remove after we upgrade to Rails 4

  gem.add_dependency "qpid_messaging", ">= 0.22.0", '<= 0.28.1'

  gem.add_dependency "gettext_i18n_rails"
  gem.add_dependency "i18n_data", ">= 0.2.6"

  # Documentation
  gem.add_dependency "maruku"

  # Pulp
  gem.add_dependency "runcible", ">= 1.3.0"
  gem.add_dependency "anemone"

  # UI
  gem.add_dependency "haml-rails"
  gem.add_dependency "deface", '< 1.0.0'
  gem.add_dependency "jquery-ui-rails"
  gem.add_dependency "bastion"
  gem.add_development_dependency "less-rails", "~> 2.5.0"

  # Testing
  gem.add_development_dependency "factory_girl_rails"
  gem.add_development_dependency "minitest-tags"
  gem.add_development_dependency "mocha"
  gem.add_development_dependency "vcr"
  gem.add_development_dependency "webmock"
  gem.add_development_dependency "rubocop-checkstyle_formatter"

end
