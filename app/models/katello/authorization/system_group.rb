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
  module Authorization::SystemGroup
    extend ActiveSupport::Concern

    READ_PERM_VERBS = [:create, :read, :update, :delete, :read_systems, :update_systems, :delete_systems]
    SYSTEM_READ_PERMS = [:read_systems, :update_systems, :delete_systems]

    module ClassMethods
      def readable(org)
        items(org, READ_PERM_VERBS)
      end

      def editable(org)
        items(org, [:update])
      end

      def systems_readable(org)
          items(org, SYSTEM_READ_PERMS)
      end

      def systems_editable(org)
        items(org, [:update_systems])
      end

      def systems_deletable(org)
        items(org, [:delete_systems])
      end

      def creatable? org
        ::User.allowed_to?([:create], :system_groups, nil, org)
      end

      def any_readable?(org)
        ::User.allowed_to?(READ_PERM_VERBS, :system_groups, nil, org)
      end

      def list_tags(org_id)
        ::SystemGroup.select('id,name').where(:organization_id=>org_id).collect { |m| VirtualTag.new(m.id, m.name) }
      end

      def tags(ids)
        select('id,name').where(:id => ids).collect { |m| VirtualTag.new(m.id, m.name) }
      end

      def list_verbs(global=false)
        {
           :create => _("Administer System Groups"),
           :read => _("Read System Group"),
           :update => _("Modify System Group details and system membership"),
           :delete => _("Delete System Group"),
           :read_systems => _("Read Systems in System Group"),
           :update_systems => _("Modify Systems in System Group"),
           :delete_systems => _("Delete Systems in System Group")
        }.with_indifferent_access
      end

      def read_verbs
        [:read]
      end

      def no_tag_verbs
        [:create]
      end

      def items(org, verbs)
        raise "scope requires an organization" if org.nil?
        resource = :system_groups
        if ::User.allowed_all_tags?(verbs, resource, org)
           where(:organization_id => org)
        else
          where("system_groups.id in (#{::User.allowed_tags_sql(verbs, resource, org)})")
        end
      end
    end

    included do
      def systems_readable?
        ::User.allowed_to?(SYSTEM_READ_PERMS, :system_groups, self.id, self.organization)
      end

      def systems_deletable?
        ::User.allowed_to?([:delete_systems], :system_groups, self.id, self.organization)
      end

      def systems_editable?
        ::User.allowed_to?([:update_systems], :system_groups, self.id, self.organization)
      end

      def readable?
        ::User.allowed_to?(READ_PERM_VERBS, :system_groups, self.id, self.organization)
      end

      def editable?
        User.allowed_to?([:update, :create], :system_groups, self.id, self.organization)
      end

      def deletable?
        ::User.allowed_to?([:delete, :create], :system_groups, self.id, self.organization)
      end
    end

  end
end
