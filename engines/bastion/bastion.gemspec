$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "bastion/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "bastion"
  s.version     = Bastion::VERSION
  s.authors     = ["Eric D Helms", "Walden Raines"]
  s.email       = ["ericdhelms@gmail.com", "walden@redhat.com"]
  s.homepage    = "https://github.com/Katello/bastion"
  s.license     = "GPL-2.0-or-later"
  s.summary     = "UI library of AngularJS based components for Foreman"
  s.description = "Bastion provides a UI library of AngularJS based components designed " \
                  "to integrate and work with Foreman."

  s.files = Dir["{app,config,lib,vendor,grunt}/**/*"] +
               ["Rakefile", "README.md", "Gruntfile.js", "package.json",
                "bower.json", "bastion.js", "eslint.yaml", ".eslintignore",
                "LICENSE", ".jshintrc"]

  s.test_files = Dir["test/**/*"]

  s.add_dependency "angular-rails-templates", "~> 1.0.2"
  s.add_development_dependency "uglifier"
end
