module Katello
  class Api::V2::PuppetModulesController < Api::V2::ApiController
    apipie_concern_subst(:a_resource => N_("a puppet module"), :resource => "puppet_modules")
    include Katello::Concerns::Api::V2::RepositoryContentController

    private

    def filter_by_content_view_version(version, options)
      repo_ids = version.default? ? version.repositories.map(&:pulp_id) : [version.archive_puppet_evironment.try(:pulp_id)]
      filter_by_repo_ids(repo_ids, options)
    end
  end
end
