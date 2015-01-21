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
    module OperatingsystemsControllerExtensions
      extend ActiveSupport::Concern

      def available_kickstart_repo
        host = Host.new
        operatingsystem = Operatingsystem.find(params[:id])
        host.operatingsystem = operatingsystem
        host.architecture = Architecture.find(params[:architecture_id])
        host.lifecycle_environment = Katello::KTEnvironment.find(params[:lifecycle_environment_id])
        host.content_view = Katello::ContentView.find(params[:content_view_id])
        host.content_source = SmartProxy.find(params[:content_source_id])

        if operatingsystem.is_a?(Redhat)
          render :json => operatingsystem.kickstart_repo(host)
        else
          render :json => nil
        end
      end

      def action_permission
        case params[:action]
        when 'available_kickstart_repo'
          'view'
        else
          super
        end
      end
    end
  end
end
