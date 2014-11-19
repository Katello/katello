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
  module Authorization::System
    extend ActiveSupport::Concern

    include Authorizable
    include Katello::Authorization

    module ClassMethods

      def readable_search_filters(_org)
        {:or => [
          {:terms => {:environment_id => KTEnvironment.readable.pluck(:id) }}
        ]
        }
      end

      def readable?(user = User.current)
        user.can?(:view_content_hosts)
      end

      def any_editable?(user = User.current)
        authorized_as(user, :edit_content_hosts).count > 0
      end

      def all_editable?(content_view, environments, user = User.current)
        systems_query = System.where(:content_view_id => content_view, :environment_id => environments)
        systems_query.count == systems_query.editable(user).count
      end
    end

  end
end
