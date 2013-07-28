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
  class ContentViewVersionsController < ApplicationController

    before_filter :find_environment
    before_filter :find_content_view_version
    before_filter :authorize

    def rules
      readable = lambda{ @view_version.content_view.readable? }
      {
        :show => readable,
        :content => readable
      }
    end

    def show
      render :partial=>"show"
    end

    def content
      render :partial=>"content",
             :locals => {:view_repos => @view_version.repos_ordered_by_product(@environment)}
    end

    private

    def find_environment
      @environment = KTEnvironment.find(params[:environment_id])
    end

    def find_content_view_version
      @view_version = ContentViewVersion.find(params[:id])
    end
  end
end
