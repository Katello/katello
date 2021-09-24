namespace :katello do
  namespace :upgrades do
    namespace '4.2' do
      desc "Removed orphaned pools and correct org+subscription mismatch"
      task :remove_checksum_values => ["environment"] do
        api = Katello::Pulp3::Api::Yum.new(SmartProxy.pulp_primary)
        repos = Katello::Pulp3::Api::Core.fetch_from_list do |page_opts|
          api.repositories_api.list(page_opts)
        end

        repos.each do |repo|
          api.repositories_api.partial_update(repo.pulp_href, {metadata_checksum_type: nil, package_checksum_type: nil})
        end
      end
    end
  end
end
