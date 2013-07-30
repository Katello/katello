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
  module Authorization::Role
    extend ActiveSupport::Concern

    READ_PERM_VERBS = [:read,:update, :create,:delete]

    included do
      scope :readable, lambda {where("0 = 1")  unless User.allowed_all_tags?(READ_PERM_VERBS, :roles)}
    end

    module ClassMethods
      def creatable?
        # TODO: ENGINIFY: assume all actions are allowed
        #User.allowed_to?([:create], :roles, nil)
        true
      end

      def editable?
        # TODO: ENGINIFY: assume all actions are allowed
        #User.allowed_to?([:update, :create], :roles, nil)
        true
      end

      def deletable?
        # TODO: ENGINIFY: assume all actions are allowed
        #User.allowed_to?([:delete, :create],:roles, nil)
        true
      end

      def any_readable?
        # TODO: ENGINIFY: assume all actions are allowed
        #User.allowed_to?(READ_PERM_VERBS, :roles, nil)
        true
      end

      def readable?
        Role.any_readable?
      end

      def list_verbs global = false
        {
        :create => _("Administer Roles"),
        :read => _("Read Roles"),
        :update => _("Modify Roles"),
        :delete => _("Delete Roles"),
        }.with_indifferent_access
      end

      def read_verbs
        [:read]
      end

      def no_tag_verbs
        [:create]
      end
    end

  end
end
