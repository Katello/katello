module Katello
  module Pulp3
    class SmartProxyRepository
      attr_accessor :smart_proxy

      def initialize(smart_proxy)
        fail "Cannot use a mirror" if smart_proxy.pulp_mirror?
        @smart_proxy = smart_proxy
      end

      def self.instance_for_type(smart_proxy)
        if smart_proxy.pulp_primary?
          SmartProxyRepository.new(smart_proxy)
        else
          SmartProxyMirrorRepository.new(smart_proxy)
        end
      end

      def ==(other)
        other.class == self.class && other.smart_proxy == smart_proxy
      end

      def current_repositories(environment_id = nil, content_view_id = nil)
        katello_repos = Katello::Repository.all
        katello_repos = katello_repos.where(:environment_id => environment_id) if environment_id
        katello_repos = katello_repos.in_content_views([content_view_id]) if content_view_id
        katello_repos = katello_repos.select { |repo| smart_proxy.pulp3_support?(repo) }
        repos_on_capsule = pulp3_enabled_repo_types.collect do |repo_type|
          repo_type.pulp3_api(smart_proxy).list_all(name_in: katello_repos.map(&:pulp_id))
        end
        repos_on_capsule.flatten!
        repo_ids = repos_on_capsule.map(&:name)
        katello_repos.select { |repo| repo_ids.include? repo.pulp_id }
      end

      def report_misconfigured_repository_version(api, href)
        errors = []
        related_distributions = if api.repository_type.publications_api_class.present?
                                  publication_hrefs = api.publications_list_all(repository_version: href).map(&:pulp_href)
                                  # Searching distributions by publication isn't supported
                                  api.distributions_list_all.select { |dist| publication_hrefs.include? dist.publication }
                                else
                                  # Searching distributions by repository version isn't supported
                                  api.distributions_list_all.select { |dist| dist.repository_version == href }
                                end
        repositories_to_redistribute = ::Katello::Repository.joins(:distribution_references)
          .where(:distribution_references => { :href => related_distributions.map(&:pulp_href) })
        if repositories_to_redistribute.present?
          warning = 'Completely resync (skip metadata check) or regenerate metadata for repositories with the following paths: ' \
                    "#{repositories_to_redistribute.map(&:relative_path).join(', ')}. " \
                    "Orphan cleanup is skipped for these repositories until they are fixed on smart proxy with ID #{smart_proxy.id}. "
          if repositories_to_redistribute.in_default_view.any?
            warning += "Try `hammer repository synchronize --skip-metadata-check 1 ...` using --id with #{repositories_to_redistribute.in_default_view.map(&:id).join(', ')}. " \
          end
          if repositories_to_redistribute.in_non_default_view.any?
            warning += "Try `hammer content-view version republish-repositories ...` using --id with #{repositories_to_redistribute.in_non_default_view.pluck(:content_view_version_id).uniq.join(', ')}." \
          end
          errors << warning
          Rails.logger.warn(warning)
        end
        Rails.logger.debug("Orphan cleanup error: investigate the version_href #{href} " \
                          "and the related distributions #{related_distributions.map(&:pulp_href)}")
        Rails.logger.debug('It is likely that the related distributions are distributing an older version of the repository.')
        errors
      end

      # See app/services/katello/pulp3/smart_proxy_mirror_repository.rb#delete_orphan_repository_versions for content proxy orphan cleanup
      def delete_orphan_repository_versions
        tasks = []
        errors = []
        orphan_repository_versions.each do |api, version_hrefs|
          version_hrefs.each do |href|
            tasks << api.repository_versions_api.delete(href)
          rescue => e
            if e.message.include?('Please update the necessary distributions first.')
              errors << report_misconfigured_repository_version(api, href)
            else
              raise e
            end
          end
        end
        { pulp_tasks: tasks.flatten, errors: errors.flatten }
      end

      def pulp3_enabled_repo_types
        Katello::RepositoryTypeManager.enabled_repository_types.values.select do |repository_type|
          smart_proxy.pulp3_repository_type_support?(repository_type)
        end
      end

      def orphan_distributions
        # Each key is a Pulp 3 plugin API and each value is the list of version_hrefs
        distribution_map = {}
        pulp3_enabled_repo_types.each do |repo_type|
          api = repo_type.pulp3_api(smart_proxy)
          katello_dist_hrefs = ::Katello::RootRepository.where(content_type: repo_type.id)
                                .joins(:repositories => :distribution_references)
                                .pluck(:href)
          pulp_dist_hrefs = api.distributions_list_all.map(&:pulp_href)
          distribution_map[api] = pulp_dist_hrefs - katello_dist_hrefs
        end

        distribution_map
      end

      def delete_orphan_distributions
        tasks = []
        orphan_distributions.each do |api, hrefs|
          tasks << hrefs.collect do |href|
            api.distributions_api.delete(href)
          end
        end
        tasks.flatten
      end

      def orphan_repository_versions
        # Each key is a Pulp 3 plugin API and each value is the list of version_hrefs
        repo_version_map = {}
        pulp3_enabled_repo_types.each do |repo_type|
          api = repo_type.pulp3_api(smart_proxy)
          version_hrefs = api.repository_versions.select { |repo_version| repo_version.number != 0 }.map(&:pulp_href)
          repo_version_map[api] = version_hrefs - ::Katello::Repository.where(version_href: version_hrefs).pluck(:version_href)
        end

        repo_version_map
      end

      def delete_orphan_repositories
        fail NotImplementedError
      end
    end
  end
end
