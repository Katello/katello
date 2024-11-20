module Katello
  module ContentViewHelper
    def separated_repo_mapping(repo_mapping, use_multicopy_actions)
      separated_mapping = { :pulp3_deb_multicopy => {}, :pulp3_yum_multicopy => {}, :other => {} }
      repo_mapping.each do |source_repos, dest_repo|
        if dest_repo.content_type == "yum" && SmartProxy.pulp_primary.pulp3_support?(dest_repo) && use_multicopy_actions
          separated_mapping[:pulp3_yum_multicopy][source_repos] = dest_repo
        elsif dest_repo.content_type == "deb" && SmartProxy.pulp_primary.pulp3_support?(dest_repo) && use_multicopy_actions
          separated_mapping[:pulp3_deb_multicopy][source_repos] = dest_repo
        else
          separated_mapping[:other][source_repos] = dest_repo
        end
      end
      separated_mapping
    end
  end
end
