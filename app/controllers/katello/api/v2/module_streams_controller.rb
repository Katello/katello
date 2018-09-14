module Katello
  class Api::V2::ModuleStreamsController < Api::V2::ApiController
    extend ::Apipie::DSL::Concern
    apipie_concern_subst(:a_resource => N_("a module stream"), :resource => "module_streams")
    include Katello::Concerns::Api::V2::RepositoryContentController

    before_action :check_hosts, :only => :index

    update_api(:index) do
      param :host_ids, Array, :desc => N_("List of host id to list available module streams for")
    end

    def custom_index_relation(collection)
      if params[:host_ids]
        collection.available_for_hosts(params[:host_ids])
      else
        collection
      end
    end

    def default_sort
      %w(name asc)
    end

    private

    def check_hosts
      if params[:host_ids] &&
        ::Host::Managed.authorized("view_hosts").where(:id => params[:host_ids]).count != params[:host_ids].count
        fail HttpErrors::NotFound, _('One or more hosts not found')
      end
    end
  end
end
