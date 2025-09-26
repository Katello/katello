namespace :katello do
  namespace :upgrades do
    namespace '4.19' do
      desc "Populate repository version PRNs for all repositories"
      task :populate_repository_version_prns => ["dynflow:client", "check_ping"] do
        User.current = User.anonymous_api_admin
        api = ::Katello::Pulp3::Api::Core.new(SmartProxy.pulp_primary)
        updates = []
        api.core_repository_versions_list_all(fields: 'pulp_href,prn').each do |repo_version|
          next if repo_version.prn.blank?
          updates << { version_href: repo_version.pulp_href, prn: repo_version.prn }
        end

        return if updates.empty?

        updates.each_slice(10_000) do |batch|
          when_clauses = batch.map do |update|
            version_href = ::Katello::Repository.connection.quote_string(update[:version_href])
            prn = ::Katello::Repository.connection.quote_string(update[:prn])
            "WHEN '#{version_href}' THEN '#{prn}'"
          end

          version_hrefs = batch.map { |u| u[:version_href] }
          case_statement = "CASE version_href #{when_clauses.join(' ')} END"

          ::Katello::Repository.where(version_href: version_hrefs)
                               .update_all("version_prn = #{case_statement}")
        end
      end
    end
  end
end
