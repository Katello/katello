module Katello
  class Api::V2::PuppetModulesController < Api::V2::ApiController
    apipie_concern_subst(:a_resource => N_("a puppet module"), :resource => "puppet_modules")
    include Katello::Concerns::Api::V2::RepositoryContentController

    def custom_index_relation(collection)
      if @environment && !@environment.library?
        collection = collection.joins(:content_view_puppet_environments).
            where("#{Katello::ContentViewPuppetEnvironment.table_name}.environment_id" => @environment.id)
      end
      collection
    end

    def custom_collection_by_content_view_version(versions)
      resource_class.joins(:content_view_puppet_environments)
        .where("#{Katello::ContentViewPuppetEnvironment.table_name}.content_view_version_id" => versions)
    end
  end
end
