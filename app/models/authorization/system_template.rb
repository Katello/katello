#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.


module Authorization::SystemTemplate
  extend ActiveSupport::Concern

  module ClassMethods
    def any_readable?(org)
      User.allowed_to?([:read_all, :manage_all], :system_templates, nil, org)
    end

    def readable?(org)
      User.allowed_to?([:read_all, :manage_all], :system_templates, nil, org)
    end

    def manageable?(org)
      User.allowed_to?([:manage_all], :system_templates, nil, org)
    end

    def list_verbs(global=false)
      {
        :manage_all => _("Administer System Templates"),
        :read_all => _("Read System Templates")
      }.with_indifferent_access
    end

    def read_verbs
      [:read_all]
    end

    def no_tag_verbs
      SystemTemplate.list_verbs.keys
    end
  end

  included do
    def readable?
      self.class.readable?(self.environment.organization)
    end
  end

end
