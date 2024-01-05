require File.expand_path("../engine", File.dirname(__FILE__))

namespace :katello do
  desc "Runs Rubocop style checker on Katello code"
  task :rubocop do
    system("bundle exec rubocop -D #{Katello::Engine.root}")
    exit($CHILD_STATUS.exitstatus)
  end
end
