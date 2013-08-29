$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "fort/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "fort"
  s.version     = Fort::VERSION
  s.authors     = ["Justin Sherrill"]
  s.email       = ["jsherril@redhat.com"]
  s.homepage    = "http://katello.org"
  s.summary     = "Katello Node Support"
  s.description = "Node supprot for katello"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["LICENSE.txt", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.12"
end
