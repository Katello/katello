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



module Authorization::Role
  READ_PERM_VERBS = [:read,:update, :create,:delete]

  def self.included(base)

    base.class_eval do

      scope :readable, lambda {where("0 = 1")  unless User.allowed_all_tags?(READ_PERM_VERBS, :roles)}

       def self.creatable?
         User.allowed_to?([:create], :roles, nil)
       end

       def self.editable?
         User.allowed_to?([:update, :create], :roles, nil)
       end

       def self.deletable?
         User.allowed_to?([:delete, :create],:roles, nil)
       end

       def self.any_readable?
         User.allowed_to?(READ_PERM_VERBS, :roles, nil)
       end

       def self.readable?
         Role.any_readable?
       end

      def self.list_verbs global = false
        {
        :create => _("Administer Roles"),
        :read => _("Read Roles"),
        :update => _("Modify Roles"),
        :delete => _("Delete Roles"),
        }.with_indifferent_access
      end

      def self.read_verbs
        [:read]
      end

      def self.no_tag_verbs
        [:create]
      end


    end
  end

end
