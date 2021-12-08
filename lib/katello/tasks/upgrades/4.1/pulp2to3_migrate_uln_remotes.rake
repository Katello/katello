namespace :katello do
  namespace :upgrades do
    namespace '4.1' do
      desc "Migrate uln-remotes to Pulp3"
      task :migrate_uln_remotes_to_pulp3 => ["environment", "check_ping"] do
        User.current = User.anonymous_api_admin
        roots = Katello::RootRepository.yum_type.where('url LIKE :uln_url', uln_url: 'uln://%')

        roots.find_each.with_index do |root, index|
          puts "Processing ULN RootRepository #{index + 1}/#{roots.count}: #{root.name} (#{root.id})"
          old_remotes = root.repositories.select(:remote_href).distinct.pluck(:remote_href).delete_if{ |x| x.nil? || x.empty? }

          # skip if already migrated
          unless old_remotes.any? { |href| href&.starts_with?('/pulp/api/v3/remotes/rpm/rpm/') }
            puts '  skipping; already migrated!'
            next
          end

          library_repo = root.library_instance

          # Create new uln-remote
          smart_proxy = SmartProxy.pulp_primary
          pulp3_repo = library_repo.backend_service(smart_proxy)
          pulp3_repo.create_remote
          puts "  created new remote #{library_repo.remote_href}"

          # attach to all repositories
          root.repositories.update(remote_href: library_repo.remote_href)

          # remove old remotes
          old_remotes.each do |href|
            puts "  removing old remote #{href}"
            pulp3_repo.api.ignore_404_exception { pulp3_repo.api.remotes_api.delete(href) }
          end
        end
      end
    end
  end
end
