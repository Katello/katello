$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "katello/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |gem|
  gem.name        = "katello"
  gem.version     = Katello::VERSION
  gem.license     = 'GPL-2.0'
  gem.authors     = ["N/A"]
  gem.email       = ["katello-devel@redhat.com"]
  gem.homepage    = "http://www.katello.org"
  gem.summary     = "Content and Subscription Management plugin for Foreman"
  gem.description = "Katello adds Content and Subscription Management to Foreman. For this it relies on Candlepin and Pulp."
  gem.required_ruby_version = '>= 2.7', '< 4'

  gem.files = Dir["{app,webpack,vendor,lib,db,ca,config,locale}/**/*"] +
    Dir['LICENSE.txt', 'README.md', 'package.json']
  gem.files += Dir["engines/bastion/{app,vendor,lib,config}/**/*"]
  gem.files += Dir["engines/bastion/{README.md}"]
  gem.files += Dir["engines/bastion_katello/{app,vendor,lib,config}/**/*"]
  gem.files += Dir["engines/bastion_katello/{README.md}"]
  gem.files -= ["lib/katello/tasks/annotate_scenarios.rake"]
  gem.files -= Dir["locale/**/*.edit.po"]

  gem.require_paths = ["lib"]

  # Core Dependencies
  gem.add_dependency "rails"
  gem.add_dependency "json"
  gem.add_dependency "oauth"
  gem.add_dependency "rest-client"

  gem.add_dependency "rabl"
  gem.add_dependency "foreman-tasks", ">= 9.1"
  gem.add_dependency "foreman_remote_execution", ">= 7.1.0"
  gem.add_dependency "dynflow", ">= 1.6.1"
  gem.add_dependency "activerecord-import"
  gem.add_dependency "stomp"
  gem.add_dependency "scoped_search", ">= 4.1.9"

  gem.add_dependency "gettext_i18n_rails"
  gem.add_dependency "apipie-rails", ">= 0.5.14"

  gem.add_dependency "fx", "< 1.0"

  gem.add_dependency "pg"

  # Required for repo discovery
  gem.add_dependency "spidr"

  # Pulp dependencies
  gem.add_dependency "pulpcore_client", ">= 3.49.1", "< 3.50.0", "!= 3.49.14"
  gem.add_dependency "pulp_file_client", ">= 3.49.1", "< 3.50.0", "!= 3.49.14"
  gem.add_dependency "pulp_ansible_client", ">= 0.21.3", "< 0.22.0"
  gem.add_dependency "pulp_container_client", ">= 2.20.0", "< 2.21.0"
  gem.add_dependency "pulp_deb_client", ">= 3.2.0", "< 3.3.0"
  gem.add_dependency "pulp_rpm_client", ">= 3.26.1", "< 3.27.0"
  gem.add_dependency "pulp_certguard_client", ">= 3.49.1", "< 3.50.0", "!= 3.49.14"
  gem.add_dependency "pulp_python_client", ">= 3.11.0", "< 3.12.0"
  gem.add_dependency "pulp_ostree_client", ">= 2.3.0", "< 2.4.0"

  # UI
  gem.add_dependency "deface", '>= 1.0.2', '< 2.0.0'
  gem.add_dependency "angular-rails-templates", "~> 1.2.0"
end
