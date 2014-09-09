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
module Ext
  module LabelFromName
    def self.included(base)
      base.class_eval do
        before_validation :setup_label_from_name
        validate :label_not_changed, :on => :update
      end
    end

    def setup_label_from_name
      unless label.present?
        self.label = Util::Model.labelize(name)
        if self.class.where(:label => self.label).any?
          self.label = Util::Model.uuid
        end
      end
    end

    def label_not_changed
      if label_changed?
        errors.add(:label, _("cannot be changed."))
      end
    end
  end
end
end
