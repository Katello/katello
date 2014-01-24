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
  class Api::V2::RepositoriesBulkActionsController < Api::V2::ApiController

    before_filter :find_organization
    before_filter :find_repositories
    before_filter :authorize

    def rules
      all_deletable = lambda{ Repository.all_deletable(@repositories) }
      all_syncable = lambda{ Repository.all_syncable(@organization) }
      hash = {
          :destroy_repositories => all_deletable,
          :sync_repositories => all_syncable
      }
      hash
    end

    api :PUT, "/repositories/bulk/destroy", "Destroy one or more repositories"
    param :ids, Array, :desc => "List of repository ids", :required => true
    def destroy_repositories
      display_messages = []

      @repositories.each{ |repository| repository.destroy }
      display_messages << _("Successfully removed %s repositories") % @repositories.length
      respond_for_show :template => 'bulk_action', :resource => { 'displayMessages' => display_messages }
    end

    api :POST, "/repositories/bulk/sync", "Synchronise repository"
    param :ids, Array, :desc => "List of repository ids", :required => true
    def sync_repositories
      display_messages = []

      @repositories.each{ |repository| repository.sync }
      display_messages << _("Successfully synced %s repositories") % @repositories.length
      respond_for_show :template => 'bulk_action', :resource => { 'displayMessages' => display_messages }
    end

    private

    def find_repositories
      params.require(:ids)
      @repositories = params[:ids].map { |id| Repository.find(id) }
    end

  end
end
