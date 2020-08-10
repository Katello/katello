module Katello
  module ContentViewHelper
    def separated_repo_mapping(repo_mapping)
      separated_mapping = { :pulp3_yum => {}, :other => {} }
      repo_mapping.each do |source_repos, dest_repo|
        if dest_repo.content_type == "yum" && SmartProxy.pulp_master.pulp3_support?(dest_repo)
          separated_mapping[:pulp3_yum][source_repos] = dest_repo
        else
          separated_mapping[:other][source_repos] = dest_repo
        end
      end
      separated_mapping
    end
  end
end
