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
    before_filter :find_repositories

    api :PUT, "/repositories/bulk/destroy", N_("Destroy one or more repositories")
    param :ids, Array, :desc => N_("List of repository ids"), :required => true
    def destroy_repositories
      deletion_authorized_repositories = @repositories.deletable
      unpromoted_repos = deletion_authorized_repositories.reject { |repo| repo.promoted? }
      deletable_repositories = unpromoted_repos.reject { |repo| repo.redhat? }

      messages1 = format_bulk_action_messages(
          :success    => "",
          :error      => _("You do not have permissions to delete %s"),
          :models     => @repositories,
          :authorized => deletion_authorized_repositories
      )

      messages2 = format_bulk_action_messages(
          :success    => "",
          :error      => _("Repository %s cannot be deleted since it has already been included in a published Content View."),
          :models     => deletion_authorized_repositories,
          :authorized => unpromoted_repos
      )

      messages3 = format_bulk_action_messages(
          :success    => "",
          :error      => _("Repository %s cannot be deleted since they are Red Hat repositories."),
          :models     => unpromoted_repos,
          :authorized => deletable_repositories
      )

      errors = messages3[:error] + messages1[:error] + messages2[:error]

      task = nil
      if deletable_repositories.count > 0
        task = async_task(::Actions::BulkAction, ::Actions::Katello::Repository::Destroy, deletable_repositories)
      else
        status = 400
      end
      respond_for_bulk_async :resource => OpenStruct.new(:task => task, :errors => errors), :status => status
    end

    api :POST, "/repositories/bulk/sync", N_("Synchronize repository")
    param :ids, Array, :desc => N_("List of repository ids"), :required => true
    def sync_repositories
      syncable_repositories = @repositories.syncable.has_url
      if syncable_repositories.empty?
        msg = _("Unable to synchronize any repository. You either do not have the permission to"\
                " synchronize or the selected repositories do not have a feed url.")
        fail HttpErrors::UnprocessableEntity, msg
      else
        task = async_task(::Actions::BulkAction,
                          ::Actions::Katello::Repository::Sync,
                          syncable_repositories)

        respond_for_async :resource => task
      end
    end

    private

    def find_repositories
      params.require(:ids)
      @repositories = Repository.where(:id => params[:ids])
    end
  end
end
