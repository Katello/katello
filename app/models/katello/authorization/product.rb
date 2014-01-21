#
# Copyright 2013 Red Hat, Inc.
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
        scope :readable, lambda{|org| all_readable(org).with_enabled_repos_only(org.library)}
        scope :editable, lambda {|org| all_editable(org).with_enabled_repos_only(org.library)}
        scope :syncable, lambda {|org| sync_items(org).with_enabled_repos_only(org.library)}

        def readable?
          Katello::Product.all_readable(self.organization).where(:id => id).count > 0
        end

        def syncable?
          Katello::Product.syncable(self.organization).where(:id => id).count > 0
        end

        def editable?
          Katello::Product.all_editable(self.organization).where(:id => id).count > 0
        end

        def deletable?
          promoted_repos = repositories.select { |repo| repo.promoted? }
          editable? && promoted_repos.empty?
        end

      end # included

      module ClassMethods

        def all_readable(org)
          Katello::Product.where(:provider_id => Katello::Provider.readable(org).pluck(:id))
        end

        def all_editable(org)
          Katello::Product.where(:provider_id => Katello::Provider.editable(org).where(:provider_type => Katello::Provider::CUSTOM).pluck(:id))
        end

        def creatable?(provider)
          provider.editable?
        end

        def any_readable?(org)
          Katello::Provider.any_readable?(org)
        end

        def sync_items(org)
          org.syncable? ? (joins(:provider).where("#{Katello::Provider.table_name}.organization_id" => org)) : where("0=1")
        end

      end # ClassMethods

    end # Product
  end # Authorization
end # Katello
