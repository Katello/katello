module Katello
  class Api::V2::ModuleStreamsController < Api::V2::ApiController
    extend ::Apipie::DSL::Concern
    apipie_concern_subst(:a_resource => N_("a module stream"), :resource => "module_streams")
    include Katello::Concerns::Api::V2::RepositoryContentController

    before_action :check_params, :only => :index

    # updating params inherited from Katello::Concerns::Api::V2::RepositoryContentController
    apipie_update_params([:index]) do
      param :host_ids, Array, :desc => N_("List of host id to list available module streams for")
      param :name_stream_only, :boolean, :desc => N_("Return name and stream information only)")
    end
    add_scoped_search_description_for(ModuleStream)
    def index
      if @name_stream_only
        sort_by, sort_order, options = sort_options
        options[:group] = [:name, :stream]
        respond(:collection => scoped_search(index_relation, sort_by, sort_order, options),
                :template => 'name_streams')
      else
        super
      end
    end

    def custom_index_relation(collection)
      if @host_ids
        collection.available_for_hosts(@host_ids)
      else
        collection
      end
    end

    def default_sort
      %w(name asc)
    end

    def available_for_content_view_filter(filter, _collection)
      collection_name_streams = []
      current_name_streams = filter.module_stream_rules.pluck(:name, :stream)
      filter.applicable_repos.each do |repo|
        collection_name_streams.concat(repo.module_streams.pluck(:name, :stream))
      end
      ModuleStream.in_repositories(filter.applicable_repos).
                    uniquify_by_name_streams(collection_name_streams - current_name_streams)
    end

    def filter_by_content_view(filter, collection)
      repos = Katello::ContentView.find(filter.content_view_id).repositories
      ids = repos.map { |r| r.send(:module_stream_ids) }.flatten
      filter_by_ids(ids, collection)
    end

    def filter_by_content_view_filter(filter, collection)
      collection.uniquify_by_name_streams(filter.module_stream_rules.pluck(:name, :stream))
    end

    private

    def check_params
      @name_stream_only = ::Foreman::Cast.to_bool(params[:name_stream_only])

      if params[:host_ids]
        @host_ids = params[:host_ids].is_a?(Array) ? params[:host_ids] : params[:host_ids].split(",")
        if ::Host::Managed.authorized("view_hosts").where(:id => @host_ids).count != @host_ids.count
          fail HttpErrors::NotFound, _('One or more hosts not found')
        end
      end
    end
  end
end
