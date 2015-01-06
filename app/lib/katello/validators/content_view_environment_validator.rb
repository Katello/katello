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
  module Validators
    class ContentViewEnvironmentValidator < ActiveModel::Validator
      def validate(record)
        #support lifecycle_environment_id for foreman models
        environment_id = record.respond_to?(:lifecycle_environment_id) ? record.lifecycle_environment_id : record.environment_id

        if record.content_view_id && environment_id
          view = ContentView.find(record.content_view_id)
          env = KTEnvironment.find(environment_id)
          unless view.in_environment?(env)
            record.errors[:base] << _("Content view '%{view}' is not in environment '%{env}'") %
                                      {:view => view.name, :env => env.name}
          end
        end
      end
    end
  end
end
