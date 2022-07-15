require File.expand_path("../engine", File.dirname(__FILE__))

namespace :katello do
  desc "Reindex DockerMetaTags in response to Redmine #35233"
  task :correct_docker_meta_tags => ['check_ping'] do
    puts 'DockerMetaTag correction running'
    Katello::Pulp3::MigrationSwitchover.new(SmartProxy.pulp_primary).correct_docker_meta_tags
    puts 'DockerMetaTag correction complete'
  end
end
