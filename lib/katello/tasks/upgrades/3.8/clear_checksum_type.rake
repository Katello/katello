namespace :katello do
  namespace :upgrades do
    namespace '3.8' do
      desc "Clear checksum type for on-demand repositories"
      task :clear_checksum_type => %w(environment) do
        User.current = User.anonymous_admin

        Katello::Repository.yum_type.find_each do |repo|
          repo.transaction do
            begin
              if repo.on_demand? && repo.url.present?
                repo.update_attribute(:checksum_type, nil)

                if repo.find_distributor[:config]&.delete(:checksum_type)
                  Katello.pulp_server.resources.repository.update_distributor(
                    repo.pulp_id, repo.find_distributor[:id], repo.find_distributor[:config])
                end
              end

              if repo.library_instance?
                repo.update_attributes!(
                  source_repo_checksum_type: repo.pulp_scratchpad_checksum_type)
              end
            # rubocop:disable HandleExceptions
            rescue RestClient::ResourceNotFound
            end
          end
        end
      end
    end
  end
end
