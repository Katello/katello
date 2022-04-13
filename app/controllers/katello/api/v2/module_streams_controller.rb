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

    def all_for_content_view_filter(filter, _collection)
      available_ids = ModuleStream.joins(:repositories).merge(filter.applicable_repos)&.pluck(:id) || []
      added_ids = filter&.module_stream_rules&.pluck(:module_stream_id) || []
      ModuleStream.where(id: available_ids + added_ids)
    end

    def available_for_content_view_filter(filter, _collection)
      collection_ids = []
      current_ids = filter.module_stream_rules.map(&:module_stream_id)
      filter.applicable_repos.each do |repo|
        collection_ids.concat(repo.module_stream_ids)
      end
      collection = ModuleStream.where(:id => collection_ids)
      collection = collection.where("id not in (?)", current_ids) unless current_ids.empty?
      collection
    end

    def filter_by_content_view(filter, collection)
      repos = Katello::ContentView.find(filter.content_view_id).repositories
      ids = repos.map { |r| r.send(:module_stream_ids) }.flatten
      filter_by_ids(ids, collection)
    end

    def filter_by_content_view_filter(filter, collection)
      collection.where(:id => filter.module_stream_rules.pluck(:module_stream_id))
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
