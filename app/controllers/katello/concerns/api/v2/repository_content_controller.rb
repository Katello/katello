module Katello
  module Concerns
    module Api::V2::RepositoryContentController
      extend ActiveSupport::Concern

      included do
        include Katello::Concerns::FilteredAutoCompleteSearch

        before_filter :find_repository
        before_filter :find_optional_organization, :only => [:index, :auto_complete_search]
        before_filter :find_environment, :only => [:index, :auto_complete_search]
        before_filter :find_content_view_version, :only => [:index, :auto_complete_search]
        before_filter :find_filter, :only => [:index, :auto_complete_search]
        before_filter :find_content_resource, :only => [:show]
      end

      extend ::Apipie::DSL::Concern

      api :GET, "/:resource_id", N_("List :resource_id")
      api :GET, "/content_views/:content_view_id/filters/:filter_id/:resource_id", N_("List :resource_id")
      api :GET, "/content_view_filters/:content_view_filter_id/:resource_id", N_("List :resource_id")
      api :GET, "/repositories/:repository_id/:resource_id", N_("List :resource_id")
      param :organization_id, :number, :desc => N_("organization identifier")
      param :content_view_version_id, :identifier, :desc => N_("content view version identifier")
      param :content_view_filter_id, :identifier, :desc => N_("content view filter identifier")
      param :repository_id, :number, :desc => N_("repository identifier")
      param :environment_id, :number, :desc => N_("environment identifier")
      param :ids, Array, :desc => N_("ids to filter content by")
      param_group :search, ::Katello::Api::V2::ApiController
      def index
        sort_options = []
        options = {}
        if default_sort.is_a?(Array)
          sort_options = default_sort
        elsif default_sort.is_a?(Proc)
          options[:custom_sort] =  default_sort
        else
          fail "Unsupported default_sort type"
        end

        respond(:collection => scoped_search(index_relation.uniq, sort_options[0], sort_options[1], options))
      end

      api :GET, "/:resource_id/:id", N_("Show :a_resource")
      api :GET, "/repositories/:repository_id/:resource_id/:id", N_("Show :a_resource")
      param :repository_id, :number, :desc => N_("repository identifier")
      param :id, String, :desc => N_(":a_resource identifier"), :required => true
      def show
        respond :resource => @resource
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

        collection = resource_class.all
        repos = Katello::Repository.where(:content_view_version_id => @versions.pluck(:id))
        repos = repos.where(:library_instance_id => @repo.id) if @repo

        collection = scoped_search(filter_by_repos(repos, collection).uniq, default_sort[0], default_sort[1])
        collection[:results] = collection[:results].map { |item| ContentViewVersionComparePresenter.new(item, @versions, @repo) }
        respond_for_index(:collection => collection)
      end

      param :available_for, :string, :desc => N_("Show available to be added to content view filter")
      param :filterId, :integer, :desc => N_("Content View Filter id")
      def index_relation
        collection = resource_class.all
        collection = filter_by_repos(Repository.readable, collection)
        collection = filter_by_repos([@repo], collection) if @repo
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
        @resource = resource_class.with_identifiers(params[:id]).first

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

      def find_repository
        if params[:repository_id]
          @repo = Repository.readable.find_by(:id => params[:repository_id])
          fail HttpErrors::NotFound, _("Couldn't find repository '%s'") % params[:repository_id] if @repo.nil?
        end
      end

      def find_environment
        if params[:environment_id]
          @environment = KTEnvironment.readable.find_by(:id => params[:environment_id])
          fail HttpErrors::NotFound, _("Could not find Lifecycle Environment with id '%{id}'.") %
            {id: params[:environment_id]} if @environment.nil?
        end
      end

      def find_content_view_version
        if params[:content_view_version_id]
          @version = ContentViewVersion.readable.find_by(:id => params[:content_view_version_id])
          fail HttpErrors::NotFound, _("Couldn't find content view version '%s'") % params[:content_view_version_id] if @version.nil?
        end
      end

      def find_filter
        # TODO: in v2.rb some routes use "filters", others use "content_view_filters"
        filter_id = params[:content_view_filter_id] || params[:filter_id]

        if filter_id
          scoped = ContentViewFilter.all
          @filter = scoped.where(:type => filter_class_name).find_by(:id => filter_id)

          unless @filter
            fail HttpErrors::NotFound, _("Couldn't find %{type} Filter with id %{id}") %
              {:type => resource_name, :id => params[:filter_id]}
          end
        end
      end

      def resource_class
        "Katello::#{controller_name.classify}".constantize
      end

      def singular_resource_name
        controller_name.singularize
      end

      def filter_class_name
        "Katello::ContentView#{controller_name.classify}Filter"
      end

      def resource_name(_i18n = true)
        case resource_class.to_s
        when "Katello::Erratum"
          _("Erratum")
        when "Katello::Rpm"
          _("Package")
        when "Katello::PackageGroup"
          _("Package Group")
        when "Katello::PuppetModule"
          _("Puppet Module")
        when "Katello::DockerManifest"
          _("Docker Manifest")
        when "Katello::DockerImage"
          _("Docker Image")
        when "Katello::DockerTag"
          _("Docker Tag")
        else
          fail "Can't find resource class: #{resource_class}"
        end
      end

      def repo_association
        :repoids
      end

      def check_repo_for_content_resource
        if params[:repository_id] && !@resource.send(repo_association).include?(@repo.pulp_id)
          fail HttpErrors::NotFound, _("Could not find %{content} with id '%{id}' in repository.") %
            {content: resource_name, id: params[:id]}
        end
      end
    end
  end
end
