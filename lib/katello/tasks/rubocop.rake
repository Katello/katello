require File.expand_path("../engine", File.dirname(__FILE__))

namespace :katello do

  task :rubocop do
    system("cd #{Katello::Engine.root} && rubocop")
  end

end
