$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "bastion_katello/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "bastion_katello"
  s.version     = BastionKatello::VERSION
  s.authors     = [""]
  s.email       = [""]
  s.homepage    = "http://www.katello.org"
  s.summary     = "UI components for Katello."
  s.description = "UI components for Katello."

  s.files = Dir["{app,config,lib}/**/*"] + ["README"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "bastion"
end
