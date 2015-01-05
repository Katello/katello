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
    module Api::V2::RepositoryDbContentController
      extend ActiveSupport::Concern

      included do
        include Katello::Concerns::FilteredAutoCompleteSearch
        before_filter :find_optional_organization, :only => [:index]
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

      def index_relation
        collection = resource_class.scoped
        collection = filter_by_repos(Repository.readable, collection)
        collection = filter_by_repos([@repo], collection) if @repo && !@repo.puppet?
        collection = filter_by_content_view_filter(@filter, collection) if @filter
        collection = filter_by_content_view_version(@version, collection) if @version
        collection = filter_by_environment(@environment, collection) if @environment
        collection = filter_by_repos(Repository.readable.in_organization(@organization), collection) if @organization
        collection = filter_by_ids(params[:ids], collection) if params[:ids]
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
        @resource = resource_class.with_uuid(params[:id]).first
        if resource_class == Katello::Erratum
          # also try to look up erratum by errata_id
          @resource ||= Erratum.find_by_errata_id(params[:id])
        end

        if @resource.nil?
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
