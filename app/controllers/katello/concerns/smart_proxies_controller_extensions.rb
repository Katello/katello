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
    module SmartProxiesControllerExtensions
      extend ActiveSupport::Concern

      include ForemanTasks::Triggers

      included do
        alias_method_chain :update, :lifecycle_environments
      end

      def update_with_lifecycle_environments
        if params[:smart_proxy][:lifecycle_environment_ids]
          modify_lifecycle_environments(params[:smart_proxy].delete(:lifecycle_environment_ids))
        end
        update_without_lifecycle_environments
      end

      private

      def modify_lifecycle_environments(ids)
        capsule = CapsuleContent.new(@smart_proxy)
        envs = KTEnvironment.where(:id => ids)
        unless capsule.default_capsule?
          to_add = envs - capsule.lifecycle_environments
          to_remove = capsule.lifecycle_environments - envs

          if to_add.any?
            to_add.each do |environment|
              sync_task(::Actions::Katello::CapsuleContent::AddLifecycleEnvironment,
                        capsule, environment)
            end
          end

          if to_remove.any?
            to_remove.each do |environment|
              sync_task(::Actions::Katello::CapsuleContent::RemoveLifecycleEnvironment,
                        capsule, environment)
            end
          end
        end
      end
    end
  end
end
