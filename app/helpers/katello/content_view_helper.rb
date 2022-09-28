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
      bad_repo = content_view.repositories.yum_type.find do |repo|
        ::Katello::Resources::Candlepin::Content.get(repo.organization.label, repo.root.content_id)
        nil
      rescue RestClient::NotFound
        repo
      end

      return if bad_repo.blank?
      if bad_repo.redhat?
        fail _("Repository: %{repo}, Product: %{product} in the content view does not have a valid subscription. "\
               " Either remove the invalid repository or try refreshing the manifest before publishing again. " %
               { repo: bad_repo.name,
                 product: bad_repo.product.name
               })
      else
        fail _("Repository: %{repo}, Product: %{product} in the content view does not have a valid subscription. "\
               " Remove the invalid repository before publishing again. " %
               { repo: bad_repo.name,
                 product: bad_repo.product.name
               })
      end
    end
  end
end
