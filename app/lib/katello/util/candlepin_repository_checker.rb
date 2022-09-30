module Katello
  module Util
    module CandlepinRepositoryChecker
      def self.check_repositories_for_promote!(content_view_version)
        bad_repo = content_view_version.repositories.yum_type.find { |repo| !repository_exist_in_backend?(repo) }
        return if bad_repo.blank?
        item = _("Content View Version: '%{cvv}', Product: '%{product}', Repository: '%{repo}' " %
                  { repo: bad_repo.name, product: bad_repo.product.name, cvv: content_view_version.name })

        if bad_repo.redhat?
          fail _("'%{item}' does not exist in the backend system [ Candlepin ]. "\
                 " Either remove the invalid repository or try refreshing "\
                 "the manifest before promoting. " % { item: item })
        else
          fail _("'%{item}' does not exist in the backend system [ Candlepin ]. "\
                 " Remove the invalid repository before promoting. " % { item: item })
        end
      end

      def self.check_repository_for_sync!(repo)
        return if !repo.yum? || repository_exist_in_backend?(repo)
        item = _("Product: '%{product}', Repository: '%{repo}' " %
                  { repo: repo.name, product: repo.product.name })

        if repo.redhat?
          fail _("%{item} does not have a valid subscription. "\
                 " Either remove and re-enable the repository or try refreshing "\
                 "the manifest before synchronizing. " % { item: item })
        else
          fail _("%{item} does not have a valid subscription. "\
                 " Remove and recreate the repository before synchronizing. " % { item: item })
        end
      end

      def self.repository_exist_in_backend?(repository)
        ::Katello::Resources::Candlepin::Content.get(repository.organization.label, repository.root.content_id)
        true
      rescue RestClient::NotFound
        false
      end

      def self.check_repositories_for_publish!(content_view)
        if content_view.composite?
          content_view.components.each do |cvv|
            check_repositories_for_content_view_publish!(cvv.repositories, component_version: cvv)
          end
        else
          check_repositories_for_content_view_publish!(content_view.repositories)
        end
      end

      def self.check_repositories_for_content_view_publish!(repositories, component_version: nil)
        bad_repo = repositories.yum_type.find { |repo| !repository_exist_in_backend?(repo) }
        return if bad_repo.blank?
        if component_version
          item = _("Component Version: '%{cvv}', Product: '%{product}', Repository: '%{repo}' " %
                  { repo: bad_repo.name, product: bad_repo.product.name, cvv: component_version.name })
        else
          item = _("Product: '%{product}', Repository: '%{repo}' " %
                  { repo: bad_repo.name, product: bad_repo.product.name })
        end
        if bad_repo.redhat?
          fail _("%{item} in this content view does not have a valid subscription. "\
                 " Either remove the invalid repository or try refreshing "\
                 "the manifest before publishing again. " % { item: item })
        else
          fail _("%{item} in this content view does not have a valid subscription. "\
                 " Remove the invalid repository before publishing again. " % { item: item })
        end
      end
    end
  end
end
