require File.expand_path("../engine", File.dirname(__FILE__))

namespace :katello do

  task :rubocop do
    # TODO: figure out how to use Rubocop::RakeTask so we don't have to shell out
    fail unless system("cd #{Katello::Engine.root} && rubocop --config .rubocop.yml")
  end

end
