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

module Authorization::Product
  extend ActiveSupport::Concern

  READ_PERM_VERBS = [:read, :create, :update, :delete]

  included do
    scope :all_readable, lambda {|org| ::Provider.readable(org).joins(:provider)}
    scope :readable, lambda{|org| all_readable(org).with_enabled_repos_only(org.library)}
    scope :all_editable, lambda {|org| ::Provider.editable(org).joins(:provider)}
    scope :editable, lambda {|org| all_editable(org).with_enabled_repos_only(org.library)}
    scope :syncable, lambda {|org| sync_items(org).with_enabled_repos_only(org.library)}

    def readable?
      Product.all_readable(self.organization).where(:id => id).count > 0
    end

    def syncable?
      Product.syncable(self.organization).where(:id => id).count > 0
    end

    def editable?
      Product.all_editable(self.organization).where(:id => id).count > 0
    end
  end

  module ClassMethods
    def readable(org)
      all_readable(org).with_enabled_repos_only(org.library)
    end

    def editable(org)
      all_editable(org).with_enabled_repos_only(org.library)
    end

    def syncable(org)
      sync_items(org).with_enabled_repos_only(org.library)
    end

    def any_readable?(org)
      ::Provider.any_readable?(org)
    end

    def sync_items(org)
      org.syncable? ? (joins(:provider).where('providers.organization_id' => org)) : where("0=1")
    end
  end

end
