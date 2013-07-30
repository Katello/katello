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
  module Authorization::Organization
    extend ActiveSupport::Concern

    SYSTEMS_READABLE = [:read_systems, :register_systems, :update_systems, :delete_systems]
    DISTRIBUTORS_READABLE = [:read_distributors, :register_distributors, :update_distributors, :delete_distributors]
    READ_PERM_VERBS = [:read, :create, :update, :delete]
    SYNC_PERM_VERBS = [:sync]

    module ClassMethods
      def creatable?
        # TODO: ENGINIFY: assume all actions are allowed
        #User.allowed_to?([:create], :organizations)
        true
      end

      def any_readable?
        Organization.readable.count > 0
      end

      def list_verbs global = false
        if Katello.config.katello?
          org_verbs = {
            :update => _("Modify Organization and Administer Environments"),
            :read => _("Read Organization"),
            :read_systems => _("Read Systems"),
            :register_systems =>_("Register Systems"),
            :update_systems => _("Modify Systems"),
            :delete_systems => _("Delete Systems"),
            :read_distributors => _("Read Distributors"),
            :register_distributors =>_("Register Distributors"),
            :update_distributors => _("Modify Distributors"),
            :delete_distributors => _("Delete Distributors"),
            :sync => _("Sync Products"),
            :gpg => _("Administer GPG Keys")
         }
        else
          org_verbs = {
            :update => _("Modify Organization and Administer Environments"),
            :read => _("Read Organization"),
            :read_systems => _("Read Systems"),
            :register_systems =>_("Register Systems"),
            :update_systems => _("Modify Systems"),
            :delete_systems => _("Delete Systems"),
            :read_distributors => _("Read Distributors"),
            :register_distributors =>_("Register Distributors"),
            :update_distributors => _("Modify Distributors"),
            :delete_distributors => _("Delete Distributors"),
         }
        end
        org_verbs.merge!({
        :create => _("Administer Organization"),
        :delete => _("Delete Organization")
        }) if global
        org_verbs.with_indifferent_access
      end

      def read_verbs
        [:read, :read_systems, :read_distributors]
      end

      def no_tag_verbs
        [:create]
      end

      def authorized_items verbs, resource = :organizations
        # TODO: ENGINIFY: assume all actions are allowed
        #if !User.allowed_all_tags?(verbs, resource)
        #  where("organizations.id in (#{User.allowed_tags_sql(verbs, resource)})")
        #end
        where("1 = 1")
      end
    end


    included do

      scope :readable, lambda {authorized_items(READ_PERM_VERBS)}

      def editable?
        # TODO: ENGINIFY: assume all actions are allowed
        #User.allowed_to?([:update, :create], :organizations, nil, self)
        true
      end

      def deletable?
        # TODO: ENGINIFY: assume all actions are allowed
        #User.allowed_to?([:delete, :create], :organizations)
        true
      end

      def readable?
        # TODO: ENGINIFY: assume all actions are allowed
        #User.allowed_to?(READ_PERM_VERBS, :organizations,nil, self)
        true
      end

      def environments_manageable?
        # TODO: ENGINIFY: assume all actions are allowed
        #User.allowed_to?([:update, :create], :organizations, nil, self)
        true
      end

      def systems_readable?
        # TODO: ENGINIFY: assume all actions are allowed
        #User.allowed_to?(SYSTEMS_READABLE, :organizations, nil, self)
        true
      end

      def systems_deletable?
        # TODO: ENGINIFY: assume all actions are allowed
        #User.allowed_to?([:delete_systems], :organizations, nil, self)
        true
      end

      def systems_registerable?
        # TODO: ENGINIFY: assume all actions are allowed
        #User.allowed_to?([:register_systems], :organizations, nil, self)
        true
      end

      def any_systems_registerable?
        # TODO: ENGINIFY: assume all actions are allowed
        #systems_registerable? || User.allowed_to?([:register_systems], :environments, environment_ids, self, true)
        true
      end

      def distributors_readable?
        # TODO: ENGINIFY: assume all actions are allowed
        #User.allowed_to?(DISTRIBUTORS_READABLE, :organizations, nil, self)
        true
      end

      def distributors_deletable?
        # TODO: ENGINIFY: assume all actions are allowed
        #User.allowed_to?([:delete_distributors], :organizations, nil, self)
        true
      end

      def distributors_registerable?
        # TODO: ENGINIFY: assume all actions are allowed
        #User.allowed_to?([:register_distributors], :organizations, nil, self)
        true
      end

      def any_distributors_registerable?
        # TODO: ENGINIFY: assume all actions are allowed
        #distributors_registerable? || User.allowed_to?([:register_distributors], :environments, environment_ids, self, true)
        true
      end

      def gpg_keys_manageable?
        # TODO: ENGINIFY: assume all actions are allowed
        #::User.allowed_to?([:gpg], :organizations, nil, self)
        true
      end

      def syncable?
        # TODO: ENGINIFY: assume all actions are allowed
        #::User.allowed_to?(SYNC_PERM_VERBS, :organizations, nil, self)
        true
      end
    end

  end
end
