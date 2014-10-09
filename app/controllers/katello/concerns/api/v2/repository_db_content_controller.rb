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

      def index
        collection = if @repo && !@repo.puppet?
                       filter_by_repos([@repo])
                     elsif @filter
                       filter_by_content_view_filter(@filter)
                     elsif @version
                       filter_by_content_view_version(@version)
                     else
                       filter_by_repos(Repository.readable)
                     end

        respond(:collection => scoped_search(collection, default_sort[0], default_sort[1]))
      end

      private

      def filter_by_content_view_filter(filter)
        resource_class.where(:uuid => filter.send("#{singular_resource_name}_rules").pluck(:uuid))
      end

      def filter_by_repos(repos)
        resource_class.in_repositories(repos)
      end

      def filter_by_content_view_version(version)
        version.send(controller_name)
      end

      def find_content_resource
        @resource = resource_class.find_by_uuid(params[:id])
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
    end
  end
end
