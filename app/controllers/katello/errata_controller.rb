#
# Copyright 2013 Red Hat, Inc.
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
  class ErrataController < ApplicationController
    before_filter :lookup_errata, except: [:auto_complete]
    before_filter :find_filter
    before_filter :authorize

    def rules
      view = lambda{
        !Repository.readable_in_org(current_organization).where(
            :pulp_id=>@errata.repoids).empty?
      }

      auto_complete = lambda do
        if @def_filter
          @def_filter.content_view_definition.readable?
        else
          false
        end
      end

      {
          :show => view,
          :packages => view,
          :short_details => view,
          :auto_complete => auto_complete
      }
    end

    def show
      render :partial=>"show"
    end

    def packages
      render :partial=>"packages"
    end

    def short_details
      render :partial=>"short_details"
    end

    def auto_complete
      if @def_filter
        repos = @def_filter.products.map { |prod| prod.repos(current_organization.library) }.flatten
        repos += @def_filter.repositories
        results = Errata.autocomplete_search("#{params[:term]}*", repos.map(&:pulp_id))
        results = results.map { |erratum| {label: erratum.id_title, value: erratum.errata_id} }
      end

      render :json => results
    end

    private

    def lookup_errata
      @errata = Errata.find(params[:id])
    end

    def find_filter
      @def_filter = Filter.find_by_id(params[:filter_id])
    end

  end
end
