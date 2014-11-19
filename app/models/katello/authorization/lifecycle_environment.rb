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
  module Authorization::LifecycleEnvironment
    extend ActiveSupport::Concern

    include Authorizable
    include Katello::Authorization

    def promotable_or_removable?(user = User.current)
      authorized_as?(:promote_or_remove_content_views_to_environments, user)
    end

    module ClassMethods

      def resource_permission
        :lifecycle_environments
      end

      def promotable(user = User.current)
        authorized_as(user, :promote_or_remove_content_views_to_environments)
      end

      def promotable?(user = User.current)
        user.can?(:promote_or_remove_content_views_to_environments)
      end

      def any_promotable?(user = User.current)
        promotable(user).count > 0
      end

      def creatable?(user = User.current)
        user.can?(:create_lifecycle_environments)
      end

      def content_readable(org, user = User.current)
        readable(user).where(:organization_id => org)
      end
    end
  end
end
