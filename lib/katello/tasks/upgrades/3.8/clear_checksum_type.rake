namespace :katello do
  namespace :upgrades do
    namespace '3.8' do
      desc "Clear checksum type for on-demand repositories"
      task :clear_checksum_type => %w(environment) do
        User.current = User.anonymous_admin

        Katello::RootRepository.yum_type.find_each do |root_repo|
          root_repo.transaction do
            begin
              if root_repo.on_demand? && root_repo.url.present?
                root_repo.update_attribute(:checksum_type, nil)

                root_repo.repositories.each do |repo|
                  begin
                    repo.update_attribute(:saved_checksum_type, nil)

                    if repo.find_distributor[:config]&.delete(:checksum_type)
                      SmartProxy.pulp_master.pulp_api.resources.repository.update_distributor(
                        repo.pulp_id, repo.find_distributor[:id], repo.find_distributor[:config])
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
    end
  end
end
