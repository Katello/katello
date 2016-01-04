module Katello
  class Api::V2::PackageGroupsController < Api::V2::ApiController
    apipie_concern_subst(:a_resource => N_("a package group"), :resource => "package_groups")
    include Katello::Concerns::Api::V2::RepositoryContentController

    def available_for_content_view_filter(filter, collection)
      collection_ids = []
      current_ids = filter.package_group_rules.map(&:uuid)
      filter.applicable_repos.each do |repo|
        collection_ids.concat(repo.package_groups.map(&:uuid))
      end
      collection = PackageGroup.where(:uuid => collection_ids)
      collection = collection.where("uuid not in (?)", current_ids) unless current_ids.empty?
      collection
    end

    def default_sort
      %w(name asc)
    end

    private

    def repo_association
      :repository_id
    end
  end
end
