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



module Authorization::Provider
  READ_PERM_VERBS = [:read, :create, :update, :delete] if AppConfig.katello?
  READ_PERM_VERBS = [:read, :update] if !AppConfig.katello?

  EDIT_PERM_VERBS = [:create, :update] if AppConfig.katello?
  EDIT_PERM_VERBS = [:update] if !AppConfig.katello?

  def self.included(base)
    base.class_eval do

      def self.readable(org)
        items(org, READ_PERM_VERBS)
      end

      def self.editable(org)
        items(org, EDIT_PERM_VERBS)
      end


      def self.creatable?(org)
        User.allowed_to?([:create], :providers, nil, org)
      end

      def self.any_readable?(org)
        (AppConfig.katello? && org.syncable?) || User.allowed_to?(READ_PERM_VERBS, :providers, nil, org)
      end

      def self.read_verbs
        [:read]
      end

      def self.no_tag_verbs
        [:create]
      end

      def self.list_tags(org_id)
        custom.select('id,name').where(:organization_id=>org_id).collect { |m| VirtualTag.new(m.id, m.name) }
      end

      def self.tags(ids)
        select('id,name').where(:id => ids).collect { |m| VirtualTag.new(m.id, m.name) }
      end

      def self.list_verbs(global = false)
        if AppConfig.katello?
          {
            :create => _("Administer Providers"),
            :read => _("Read Providers"),
            :update => _("Modify Providers and Administer Products"),
            :delete => _("Delete Providers"),
          }.with_indifferent_access
        else
          {
            :read => _("Read Providers"),
            :update => _("Modify Providers and Administer Products"),
          }.with_indifferent_access
        end
      end

      def self.items(org, verbs)
        raise "scope requires an organization" if org.nil?
        resource = :providers
        if (AppConfig.katello? && verbs.include?(:read) && org.syncable?) ||  User.allowed_all_tags?(verbs, resource, org)
           where(:organization_id => org)
        else
          where("providers.id in (#{User.allowed_tags_sql(verbs, resource, org)})")
        end
      end

    end
  end



  def readable?
    return organization.readable? if redhat_provider?
    User.allowed_to?(READ_PERM_VERBS, :providers, self.id, self.organization) || (AppConfig.katello? && self.organization.syncable?)
  end

  def editable?
    return organization.editable? if redhat_provider?
    User.allowed_to?([:update, :create], :providers, self.id, self.organization)
  end

  def deletable?
    return false if redhat_provider?
    User.allowed_to?([:delete, :create], :providers, self.id, self.organization)
  end

end
