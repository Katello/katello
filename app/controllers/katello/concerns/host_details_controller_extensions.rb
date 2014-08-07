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
    module HostDetailsControllerExtensions
      extend ActiveSupport::Concern

      def kt_environment_selected
        # return content views
        respond_to do |format|
          format.json do
            if (kt_environment = Katello::KTEnvironment.find(params[:kt_environment_id]))
              render :json => Katello::ContentView.in_environment(kt_environment).with_available_versions_in_puppet_environment
            else
              not_found
            end
          end
        end
      end

      def content_view_selected
        # # return default puppet environment given kt_environment and content_view
        respond_to do |format|
          format.json do
            if (content_view_versions = Katello::ContentViewVersion.where(:content_view_id => params[:content_view_id])) &&
               (kt_environment        = Katello::KTEnvironment.find(params[:kt_environment_id]))
                 ids = Katello::ContentViewPuppetEnvironment.where(:environment_id => 1, :content_view_version_id => [2,3,4]).pluck(:puppet_environment_id)
                render :json => ::Environment.where(:id => ids)
            else
              not_found
            end
          end
        end
      end

    end
  end
end
