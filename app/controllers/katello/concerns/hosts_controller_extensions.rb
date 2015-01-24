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
    module HostsControllerExtensions
      extend ActiveSupport::Concern
      include ForemanTasks::Triggers
      included do
        def destroy
          sync_task(::Actions::Katello::System::HostDestroy, @host)
          process_success(:object => @host)
        rescue StandardError => ex
          process_error(:object => @host, :error_msg => ex.message)
        end

        def puppet_environment_for_content_view
          view = Katello::ContentView.find(params[:content_view_id])
          environment = Katello::KTEnvironment.find(params[:lifecycle_environment_id])
          version = view.version(environment)
          cvpe = Katello::ContentViewPuppetEnvironment.where(:environment_id => environment, :content_view_version_id => version).first
          render :json => cvpe.nil? ? nil : {:name => cvpe.puppet_environment.name, :id => cvpe.puppet_environment.id}
        end
      end
    end
  end
end
