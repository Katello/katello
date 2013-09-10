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

module Authorization::User
  extend ActiveSupport::Concern

  READ_PERM_VERBS = [:read, :update, :create, :delete]

  module ClassMethods
    def creatable?
      User.allowed_to?([:create], :users, nil)
    end

    def any_readable?
      User.allowed_to?(READ_PERM_VERBS, :users, nil)
    end

    def list_verbs(global = false)
      { :create => _("Administer Users"),
        :read   => _("Read Users"),
        :update => _("Modify Users"),
        :delete => _("Delete Users")
      }.with_indifferent_access
    end

    def read_verbs
      [:read]
    end

    def no_tag_verbs
      [:create]
    end
  end

  included do

    # scope
    def readable
      User.allowed_all_tags?(READ_PERM_VERBS, :users) ? where(:hidden => false) : where("0 = 1")
    end

    def readable?
      User.any_readable? && !hidden
    end

    def editable?
      User.allowed_to?([:create, :update], :users, nil) && !hidden
    end

    def deletable?
      self.id != User.current.id && User.allowed_to?([:delete], :users, nil)
    end

    def allowed_organizations
      #test for all orgs
      perms = ::Permission.joins(:role).joins("INNER JOIN roles_users ON roles_users.role_id = roles.id").
          where("roles_users.user_id = ?", self.id).where(:organization_id => nil).count
      return ::Organization.all if perms > 0

      perms = ::Permission.joins(:role).joins("INNER JOIN roles_users ON roles_users.role_id = roles.id").
          where("roles_users.user_id = ?", self.id).where("organization_id is NOT null")
      #return the individual organizations
      perms.collect { |perm| perm.organization }.uniq
    end
  end

end
