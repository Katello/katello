module Katello
  module Concerns
    module Api::V2::RepositoryContentController
      extend ActiveSupport::Concern

      included do
        include Katello::Concerns::FilteredAutoCompleteSearch

        before_action :find_repository
        before_action :find_optional_organization, :only => [:index, :show, :auto_complete_search]
        before_action :find_environment, :only => [:index, :auto_complete_search]
        before_action :find_content_view_version, :only => [:index, :auto_complete_search]
        before_action :find_filter, :find_filter_rule, :only => [:index, :auto_complete_search]
        before_action :find_content_resource, :only => [:show]
        before_action :check_show_all_and_available_params, only: [:index]
      end

      extend ::Apipie::DSL::Concern

      api :GET, "/:resource_id", N_("List :resource_id")
      api :GET, "/content_views/:content_view_id/filters/:filter_id/:resource_id", N_("List :resource_id")
      api :GET, "/content_view_filters/:content_view_filter_id/:resource_id", N_("List :resource_id")
      api :GET, "/repositories/:repository_id/:resource_id", N_("List :resource_id")
      param :organization_id, :number, :desc => N_("organization identifier")
      param :content_view_version_id, :number, :desc => N_("content view version identifier")
      param :content_view_filter_id, :number, :desc => N_("content view filter identifier")
      param :content_view_filter_rule_id, :number, :desc => N_("content view filter rule identifier")
      param :repository_id, :number, :desc => N_("repository identifier")
      param :environment_id, :number, :desc => N_("environment identifier")
      param :ids, Array, :desc => N_("ids to filter content by")
      param_group :search, ::Katello::Api::V2::ApiController
      def index
        sort_by, sort_order, options = sort_options
        respond(:collection => scoped_search(index_relation, sort_by, sort_order, options))
      end

      api :GET, "/:resource_id/:id", N_("Show :a_resource")
      api :GET, "/repositories/:repository_id/:resource_id/:id", N_("Show :a_resource")
      param :repository_id, :number, :desc => N_("repository identifier")
      param :organization_id, :number, :desc => N_("organization identifier")
      param :id, String, :desc => N_(":a_resource identifier"), :required => true
      def show
        respond :resource => @resource
      end

      api :GET, "/:resource_id/compare/", N_("List :resource_id")
      param :content_view_version_ids, Array, :desc => N_("content view versions to compare")
      param :repository_id, :number, :desc => N_("Library repository id to restrict comparisons to")
      def compare
        fail _("No content_view_version_ids provided") if params[:content_view_version_ids].empty?
        @versions = ContentViewVersion.readable.where(:id => params[:content_view_version_ids])

        if @versions.count != params[:content_view_version_ids].uniq.length
          missing = params[:content_view_version_ids] - @versions.pluck(:id)
          fail HttpErrors::NotFound, _("Couldn't find content view versions '%s'") % missing.join(',')
        end

        sort_by, sort_order, options = sort_options

        if respond_to?(:custom_collection_by_content_view_version)
          collection = custom_collection_by_content_view_version(@versions)
        else
          repos = Katello::Repository.where(:content_view_version_id => @versions.pluck(:id))
          repos = repos.where(:root_id => @repo.root_id) if @repo
          collection = filter_by_repos(repos, resource_class.all)
        end

        collection = scoped_search(collection.distinct, sort_by, sort_order, options)
        collection[:results] = collection[:results].map { |item| ContentViewVersionComparePresenter.new(item, @versions, @repo) }
        respond_for_index(:collection => collection)
      end

      param :available_for, :string, :desc => N_("Return content that can be added to the specified object.  The values 'content_view_version' and 'content_view_filter are supported.")
      param :show_all_for, :bool,
            :desc => N_("Returns content that can be both added and is currently added to the object. The value 'content_view_filter' is supported")
      param :filterId, :integer, :desc => N_("Content View Filter id")
      def index_relation
        if @version && params[:available_for] == "content_view_version" && self.respond_to?(:available_for_content_view_version)
          collection = self.available_for_content_view_version(@version)
        else
          collection = resource_class.all
          collection = filter_by_content_view_version(@version, collection) if @version
        end

        collection = filter_by_repos(repos, collection)
        collection = filter_by_ids(params[:ids], collection) if params[:ids]
        collection = handle_cv_filter(collection, @filter, @filter_rule, params) if @filter || @filter_rule

        collection = self.custom_index_relation(collection) if self.respond_to?(:custom_index_relation)
        collection
      end

      private

      def default_sort
        %w(id desc)
      end

      def sort_options
        if default_sort.is_a?(Array)
          return [default_sort[0], default_sort[1], {}]
        elsif default_sort.is_a?(Proc)
          return [nil, nil, { :custom_sort => default_sort }]
        else
          fail "Unsupported default_sort type"
        end
      end

      def filter_by_content_view_filter(_filter, _collection)
        fail NotImplementedError, "Unsupported content type for content view filter parameter"
      end

      def filter_by_content_view_filter_rule(_filter, _collection)
        fail NotImplementedError, "Unsupported content type for content view filter rule parameter"
      end

      def repos
        repos = Repository.readable
        repos = repos.where(:id => @repo) if @repo
        repos = repos.where(:id => Repository.readable.in_organization(@organization)) if @organization
        if @environment && (@environment.library? || resource_class != Katello::PuppetModule)
          # if the environment is not library and this is for puppet modules,
          # we can skip environment filter, as those would be associated to
          # content view puppet environments and handled by the puppet modules
          # controller.
          repos = repos.where(:id => @environment.repositories)
        end
        repos
      end

      def filter_by_repos(repos, collection)
        collection.in_repositories(repos)
      end

      def filter_by_content_view_version(version, collection)
        collection.where(:id => version.send(controller_name))
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

        if params[:organization_id] && !@resource.repositories.any? { |repo| repo.organization_id == params[:organization_id].to_i }
          fail HttpErrors::BadRequest, _("The requested resource does not belong to the specified organization")
        end
      end

      def filter_by_ids(ids, collection)
        collection.with_identifiers(ids)
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
          if @environment.nil?
            fail HttpErrors::NotFound, _("Could not find Lifecycle Environment with id '%{id}'.") %
              {id: params[:environment_id]}
          end
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

      def find_filter_rule
        filter_rule_id = params[:content_view_filter_rule_id]

        if filter_rule_id
          @filter_rule = filter_rule_class_name.constantize.find_by(:id => filter_rule_id)

          unless @filter_rule
            fail HttpErrors::NotFound, _("Couldn't find %{type} Filter with id %{id}") %
              {:type => resource_name, :id => filter_rule_id}
          end
        end
      end

      def check_show_all_and_available_params
        if params[:show_all_for] && params[:available_for]
          fail HttpErrors::UnprocessableEntity, _("params 'show_all_for' and 'available_for' must be used independently")
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

      def filter_rule_class_name
        "Katello::ContentView#{controller_name.classify}FilterRule"
      end

      def resource_name(_i18n = true)
        case resource_class.to_s
        when "Katello::Erratum"
          _("Erratum")
        when "Katello::Deb"
          _("Deb Package")
        when "Katello::Rpm"
          _("Package")
        when "Katello::Srpm"
          _("Source RPM")
        when "Katello::PackageGroup"
          _("Package Group")
        when "Katello::PuppetModule"
          _("Puppet Module")
        when "Katello::DockerManifest"
          _("Container Image Manifest")
        when "Katello::DockerMetaTag"
          _("Container Image Tag")
        when "Katello::OstreeBranch"
          _("OSTree Branch")
        when "Katello::FileUnit"
          _("File")
        when "Katello::ModuleStream"
          _("Module Stream")
        when "Katello::AnsibleCollection"
          _("Ansible Collection")
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

      def handle_cv_filter(collection, filter, filter_rule, params)
        if params[:show_all_for] == "content_view_filter" && self.respond_to?(:all_for_content_view_filter)
          collection = self.all_for_content_view_filter(filter, collection)
        elsif params[:available_for] == "content_view_filter" && self.respond_to?(:available_for_content_view_filter)
          collection = self.available_for_content_view_filter(filter, collection)
        else
          # Filtering by the CV filter rule makes filtering by the CV filter redundant, keeping these
          # exclusive to keep the queries simple.
          if @filter_rule
            collection = filter_by_content_view_filter_rule(filter_rule, collection)
          elsif @filter
            collection = filter_by_content_view_filter(filter, collection)
          end
        end
        collection
      end
    end
  end
end
