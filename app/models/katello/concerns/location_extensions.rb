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
    module LocationExtensions
      extend ActiveSupport::Concern

      included do
        after_initialize :set_default_overrides, :if => :new_record?
        before_create :set_katello_default
        before_save   :refute_katello_default_changed
        before_destroy :is_deletable?
      end

      def set_default_overrides
        self.ignore_types << ::ConfigTemplate.name
        self.ignore_types << ::Hostgroup.name
      end

      def set_katello_default
        if Location.default_location.nil?
          self.katello_default = true
        else
          self.katello_default = false
        end
        true
      end

      def is_deletable?
        if self.katello_default
          errors.add(:base, _("Cannot delete the default Location"))
          false
        end
      end

      def refute_katello_default_changed
        fail _("katello_default cannot be changed.") if self.katello_default_changed?
      end

      module ClassMethods
        def default_location
          # In the future, we should have a better way to identify the 'default' location
          Location.where(:katello_default => true).first
        end
      end
    end
  end
end
