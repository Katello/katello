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
  class PuppetModulesController < ApplicationController
    before_filter :find_puppet_module, only: [:show]
    before_filter :find_filter, except: [:show]
    before_filter :authorize

    def rules
      view = lambda do
        !Repository.readable_in_org(current_organization).where(
          :pulp_id => @puppet_module.repoids).empty?
      end if @puppet_module

      auto_complete = lambda { @def_filter.content_view_definition.readable? }

      {
        :auto_complete => auto_complete,
        :author_auto_complete => auto_complete,
        :show => view
      }
    end

    def auto_complete
      if @def_filter
        repoids = @def_filter.repos(current_organization.library).map(&:pulp_id)
        results = PuppetModule.autocomplete_name("#{params[:term]}*", repoids)
      end

      render :json => results
    end

    def author_auto_complete
      if @def_filter
        name = params[:module_name]
        repoids = @def_filter.repos(current_organization.library).map(&:pulp_id)
        results = PuppetModule.autocomplete_author("#{params[:term]}*", repoids, 15, name)
      end

      render :json => results
    end

    def show
      render :partial => "show"
    end

    private

    def find_filter
      @def_filter = Filter.find(params[:filter_id])
    end

    def find_puppet_module
      @puppet_module = PuppetModule.find(params[:id])
    end

  end
end
