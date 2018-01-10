namespace :katello do
  namespace :upgrades do
    namespace '3.4' do
      desc "Reindex docker tags to account for schema 1 and schema 2"
      task :reindex_docker_tags => ["environment"] do
        User.current = User.anonymous_admin
        ::Katello::DockerManifest.import_all
        ::Katello::DockerTag.import_all
      end
    end
  end
end
