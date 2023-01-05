module Katello
  class Api::V2::PackageGroupsController < Api::V2::ApiController
    apipie_concern_subst(:a_resource => N_("a package group"), :resource => "package_groups")
    include Katello::Concerns::Api::V2::RepositoryContentController

    def available_for_content_view_filter(filter, _collection)
      collection_ids = []
      current_ids = filter.package_group_rules.map(&:uuid)
      filter.applicable_repos.each do |repo|
        collection_ids.concat(repo.package_groups.map(&:pulp_id))
      end
      collection = PackageGroup.where(:pulp_id => collection_ids)
      collection = collection.where("pulp_id not in (?)", current_ids) unless current_ids.empty?
      collection
    end

    def all_for_content_view_filter(filter, _collection)
      available_ids = PackageGroup.joins(:repositories).merge(filter.applicable_repos)&.pluck(:pulp_id) || []
      added_ids = filter&.package_group_rules&.pluck(:uuid) || []
      PackageGroup.where(pulp_id: available_ids + added_ids)
    end

    def default_sort
      %w(name asc)
    end

    def filter_by_content_view_filter(filter, collection)
      ids = filter.send("#{singular_resource_name}_rules").pluck(:uuid)
      filter_by_ids(ids, collection)
    end

    private

    def repo_association
      :repository_id
    end
  end
end
