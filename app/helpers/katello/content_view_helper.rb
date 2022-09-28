module Katello
  module ContentViewHelper
    def separated_repo_mapping(repo_mapping, use_multicopy_actions)
      separated_mapping = { :pulp3_yum_multicopy => {}, :other => {} }
      repo_mapping.each do |source_repos, dest_repo|
        if dest_repo.content_type == "yum" && SmartProxy.pulp_primary.pulp3_support?(dest_repo) && use_multicopy_actions
          separated_mapping[:pulp3_yum_multicopy][source_repos] = dest_repo
        else
          separated_mapping[:other][source_repos] = dest_repo
        end
      end
      separated_mapping
    end

    def validate_repositories_exist_in_backend!(content_view)
      if content_view.composite?
        content_view.components.each do |cvv|
          validate_repositories!(cvv.repositories, component_version: cvv)
        end
      else
        validate_repositories!(content_view.repositories)
      end
    end

    def validate_repositories!(repositories, component_version: nil)
      bad_repo = repositories.yum_type.find do |repo|
        ::Katello::Resources::Candlepin::Content.get(repo.organization.label, repo.root.content_id)
        nil
      rescue RestClient::NotFound
        repo
      end

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
