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
    module OrganizationsControllerExtensions
      extend ActiveSupport::Concern
      include ForemanTasks::Triggers

      included do
        alias_method_chain :destroy, :dynflow
      end

      def destroy_with_dynflow
        if @taxonomy.is_a?(Organization)
          begin
            async_task(::Actions::Katello::Organization::Destroy, @taxonomy,
                       ::Organization.current)
            process_success :success_msg => _("Organization %s is being deleted.") % @taxonomy.name
          rescue ::Katello::Errors::OrganizationDestroyException => ex
            process_error(:error_msg => ex.message)
          end
        else
          destroy_without_dynflow
        end
      end
    end
  end
end
