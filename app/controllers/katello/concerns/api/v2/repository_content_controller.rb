#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module Katello
  module Concerns
    module Api::V2::RepositoryContentController
      extend ActiveSupport::Concern

      included do
        before_filter :find_repository
        before_filter :find_environment, :only => [:index]
        before_filter :find_content_view_version, :only => [:index]
        before_filter :find_filter, :only => [:index]
        before_filter :find_content_resource, :only => [:show]
      end

      extend ::Apipie::DSL::Concern

      api :GET, "/:resource_id", N_("List :resource_id")
      api :GET, "/content_views/:content_view_id/filters/:filter_id/:resource_id", N_("List :resource_id")
      api :GET, "/content_view_filters/:content_view_filter_id/:resource_id", N_("List :resource_id")
      api :GET, "/repositories/:repository_id/:resource_id", N_("List :resource_id")
      param :content_view_version_id, :identifier, :desc => N_("content view version identifier")
      param :content_view_filter_id, :identifier, :desc => N_("content view filter identifier")
      param :repository_id, :number, :desc => N_("repository identifier")
      param :environment_id, :number, :desc => N_("environment identifier")
      param_group :search, ::Katello::Api::V2::ApiController
      def index
        options = sort_params
        options[:filters] = []

        options = filter_by_repo_ids(Repository.readable.map(&:pulp_id), options)
        options = filter_by_repo_ids([@repo.pulp_id], options) if @repo && !@repo.puppet?
        options = filter_by_content_view_version(@version, options) if @version
        options = filter_by_environment(@environment, options) if @environment
        options = filter_by_content_view_filter(@filter, options) if @filter

        results = item_search(resource_class, params, options)
        results[:results] = results[:results].map do  |item|
          if resource_class.respond_to?(:new_from_search)
            resource_class.new_from_search(item.as_json)
          else
            resource_class.new(item.as_json)
          end
        end

        respond(:collection => results)
      end

      api :GET, "/:resource_id/:id", N_("Show :a_resource")
      api :GET, "/repositories/:repository_id/:resource_id/:id", N_("Show :a_resource")
      param :repository_id, :number, :desc => N_("repository identifier")
      param :id, String, :desc => N_(":a_resource identifier"), :required => true
      def show
        respond :resource => @resource
      end

      private

      def find_repository
        if params[:repository_id]
          @repo = Repository.readable.find_by_id(params[:repository_id])
          fail HttpErrors::NotFound, _("Couldn't find repository '%s'") % params[:repository_id] if @repo.nil?
        end
      end

      def find_environment
        if params[:environment_id]
          @environment = KTEnvironment.readable.find_by_id(params[:environment_id])
          fail HttpErrors::NotFound, _("Could not find Lifecycle Environment with id '%{id}'.") %
            {id: params[:environment_id]} if @environment.nil?
        end
      end

      def find_content_view_version
        if params[:content_view_version_id]
          @version = ContentViewVersion.readable.find_by_id(params[:content_view_version_id])
          fail HttpErrors::NotFound, _("Couldn't find content view version '%s'") % params[:content_view_version_id] if @version.nil?
        end
      end

      def find_content_resource
        @resource = resource_class.find(params[:id])

        if @resource.nil?
          fail HttpErrors::NotFound, _("Failed to find %{content} with id '%{id}'.") %
            {content: resource_name, id: params[:id]}
        end

        if params[:repository_id] && !Array.wrap(@resource.send(repo_association)).include?(@repo.pulp_id)
          fail HttpErrors::NotFound, _("Could not find %{content} with id '%{id}' in repository.") %
            {content: resource_name, id: params[:id]}
        end
      end

      def find_filter
        # TODO: in v2.rb some routes use "filters", others use "content_view_filters"
        filter_id = params[:content_view_filter_id] || params[:filter_id]

        if filter_id
          scoped = ContentViewFilter.scoped
          @filter = scoped.where(:type => filter_class_name).find_by_id(filter_id)

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
        when "Katello::Package"
          _("Package")
        when "Katello::PackageGroup"
          _("Package Group")
        when "Katello::PuppetModule"
          _("Puppet Module")
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

      def filter_by_content_view_filter(filter, options)
        ids = filter.send("#{singular_resource_name}_rules").map(&:uuid)
        repo_ids = filter.applicable_repos.readable.select([:pulp_id, "#{Katello::Repository.table_name}.name"])

        options[:filters] << { :terms => { :id => ids } }
        filter_by_repo_ids(repo_ids, options)
      end

      def filter_by_repo_ids(repo_ids = [], options)
        options[:filters] << { :terms => { repo_association => repo_ids }}
        options
      end

      def filter_by_content_view_version(version, options)
        filter_by_repo_ids(version.archived_repos.map(&:pulp_id), options)
      end

      def filter_by_environment(environment, options)
        filter_by_repo_ids(environment.repositories.map(&:pulp_id), options)
      end
    end
  end
end
