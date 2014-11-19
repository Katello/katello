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
  module Authorization::Organization
    extend ActiveSupport::Concern

    include Authorizable
    include Katello::Authorization

    def manifest_importable?(user = User.current)
      authorized_as?(:import_manifest, user)
    end

    def readable_promotion_paths(user = User.current)
      permissible_promotion_paths(KTEnvironment.readable(user))
    end

    def promotable_promotion_paths(user = User.current)
      permissible_promotion_paths(KTEnvironment.promotable(user))
    end

    def permissible_promotion_paths(permissible_environments)
      promotion_paths.select do |promotion_path|
        # if at least one environment in the path is permissible
        # the path is deemed permissible.
        (promotion_path - permissible_environments).size != promotion_path.size
      end
    end

    def subscriptions_readable?(user = User.current)
      user.can?(:view_subscriptions)
    end

  end
end
