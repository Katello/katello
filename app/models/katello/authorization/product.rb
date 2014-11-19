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
  module Authorization
    module Product
      extend ActiveSupport::Concern

      include Authorizable
      include Katello::Authorization

      def syncable?(user = User.current)
        authorized_as?(:sync_products, user)
      end

      def deletable?(user = User.current)
        promoted_repos = repositories.select { |repo| repo.promoted? }
        authorized_as?(:destroy_products, user) && promoted_repos.empty?
      end

      module ClassMethods

        def syncable(user = User.current)
          authorized(:sync_products, user)
        end

        def readable?(user = User.current)
          user.can?(:view_products)
        end

        def readable_repositories(repo_ids = nil, user = User.current)
          query = Katello::Repository.scoped

          if repo_ids
            query = query.where(:id => repo_ids)
          end

          query.joins(:product)
               .joins(:content_view_version)
               .where("#{Katello::ContentViewVersion.table_name}.content_view_id" => Katello::ContentView.default.pluck(:id))
               .where(:product_id => Katello::Product.readable(user).pluck(:id))
        end

        def syncable?(user = User.current)
          user.can?(:sync_products)
        end
      end
    end
  end
end
