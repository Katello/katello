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

      included do
        include Authorizable
        include Katello::Authorization

        def readable?
          authorized?(:view_products)
        end

        def syncable?
          authorized?(:sync_products)
        end

        def editable?
          authorized?(:update_products)
        end

        def deletable?
          promoted_repos = repositories.select { |repo| repo.promoted? }
          authorized?(:destroy_products) && promoted_repos.empty?
        end

      end # included

      module ClassMethods

        def readable
          authorized(:view_products)
        end

        def editable
          authorized(:update_products)
        end

        def deletable
          authorized(:destroy_products)
        end

        def syncable
          authorized(:sync_products)
        end

        def readable?
          ::User.current.can?(:view_products)
        end

        def readable_repositories(repo_ids = nil)
          query = Katello::Repository

          if repo_ids
            query = query.where(:id => repo_ids)
          end

          query.joins(:product)
               .joins(:content_view_version)
               .where("#{Katello::ContentViewVersion.table_name}.content_view_id" => Katello::ContentView.default.pluck(:id))
               .where(:product_id => Katello::Product.readable.pluck(:id))
        end

      end # ClassMethods

    end # Product
  end # Authorization
end # Katello
