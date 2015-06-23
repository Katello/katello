module Katello
  module Concerns
    module Api::V2::RepositoryDbContentController
      extend ActiveSupport::Concern

      included do
        include Katello::Concerns::FilteredAutoCompleteSearch
        before_filter :find_optional_organization, :only => [:index, :auto_complete_search]
        before_filter :find_environment, :only => [:index, :auto_complete_search]
        before_filter :find_content_view_version, :only => [:index, :auto_complete_search]
        before_filter :find_filter, :only => [:index, :auto_complete_search]
        before_filter :find_content_resource, :only => [:show]
      end

      extend ::Apipie::DSL::Concern

      def index
        respond(:collection => scoped_search(index_relation.uniq, default_sort[0], default_sort[1]))
      end

      api :GET, "/compare/", N_("List :resource_id")
      param :content_view_version_ids, Array, :desc => N_("content view versions to compare")
      param :repository_id, :identifier, :desc => N_("Library repository id to restrict comparisons to")
      def compare
        fail _("No content_view_version_ids provided") if params[:content_view_version_ids].empty?
        @versions = ContentViewVersion.readable.where(:id => params[:content_view_version_ids])

        if @versions.count != params[:content_view_version_ids].uniq.length
          missing = params[:content_view_version_ids] - @versions.pluck(:id)
          fail HttpErrors::NotFound, _("Couldn't find content view versions '%s'") % missing.join(',')
        end

        collection = resource_class.scoped
        repos = Katello::Repository.where(:content_view_version_id => @versions.pluck(:id))
        repos = repos.where(:library_instance_id => @repo.id) if @repo

        collection = scoped_search(filter_by_repos(repos, collection).uniq, default_sort[0], default_sort[1])
        collection[:results] = collection[:results].map { |item| ContentViewVersionComparePresenter.new(item, @versions, @repo) }
        respond_for_index(:collection => collection)
      end

      param :available_for, :string, :desc => N_("Show available to be added to content view filter")
      param :filterId, :integer, :desc => N_("Content View Filter id")
      def index_relation
        collection = resource_class.scoped
        collection = filter_by_repos(Repository.readable, collection)
        collection = filter_by_repos([@repo], collection) if @repo && !@repo.puppet?
        collection = filter_by_content_view_version(@version, collection) if @version
        collection = filter_by_environment(@environment, collection) if @environment
        collection = filter_by_repos(Repository.readable.in_organization(@organization), collection) if @organization
        collection = filter_by_ids(params[:ids], collection) if params[:ids]
        @filter = ContentViewFilter.find(params[:filterId]) if params[:filterId]
        if params[:available_for] == "content_view_filter" && self.respond_to?(:available_for_content_view_filter)
          collection = self.available_for_content_view_filter(@filter, collection) if @filter
        else
          collection = filter_by_content_view_filter(@filter, collection) if @filter
        end
        collection = self.custom_index_relation(collection) if self.respond_to?(:custom_index_relation)
        collection
      end

      private

      def default_sort
        %w(id desc)
      end

      def filter_by_content_view_filter(filter, collection)
        ids = filter.send("#{singular_resource_name}_rules").pluck(:uuid)
        filter_by_ids(ids, collection)
      end

      def filter_by_repos(repos, collection)
        collection.in_repositories(repos)
      end

      def filter_by_content_view_version(version, collection)
        collection.where(:id => version.send(controller_name))
      end

      def filter_by_environment(environment, collection)
        filter_by_repos(environment.repositories, collection)
      end

      def find_content_resource
        begin
          id = Integer(params[:id])
          @resource = resource_class.where(:id => id).first
        rescue ArgumentError
          @resource = resource_class.where(:uuid => params[:id]).first
        end

        if resource_class == Katello::Erratum && @resource.blank?
          @resource = Erratum.find_by_errata_id(params[:id])
        end

        if @resource.blank?
          fail HttpErrors::NotFound, _("Failed to find %{content} with id '%{id}'.") %
            {content: resource_name, id: params[:id]}
        end

        if params[:repository_id] && !@resource.repositories.include?(@repo)
          fail HttpErrors::NotFound, _("Could not find %{content} with id '%{id}' in repository.") %
            {content: resource_name, id: params[:id]}
        end
      end

      def filter_by_ids(ids, collection)
        collection.with_uuid(ids)
      end
    end
  end
end
