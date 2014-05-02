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
module Authorization::HostCollection
  extend ActiveSupport::Concern

  READ_PERM_VERBS = [:create, :read, :update, :delete, :read_content_hosts, :update_content_hosts, :delete_content_hosts]
  SYSTEM_READ_PERMS = [:read_content_hosts, :update_content_hosts, :delete_content_hosts]

  module ClassMethods
    def readable(org)
      items(org, READ_PERM_VERBS)
    end

    def editable(org)
      items(org, [:update])
    end

    def content_hosts_readable(org)
      items(org, SYSTEM_READ_PERMS)
    end

    def content_hosts_editable(org)
      items(org, [:update_content_hosts])
    end

    def content_hosts_deletable(org)
      items(org, [:delete_content_hosts])
    end

    def assert_editable(host_collections)
      invalid_perms = host_collections.select{ |host_collection| !host_collection.editable? }.collect{ |host_collection| host_collection.name }

      unless invalid_perms.empty?
        fail Errors::SecurityViolation, _("Collection membership modification is not allowed for host collections(s): %s") % invalid_perms.join(', ')
      end
      true
    end

    def creatable?(org)
      ::User.allowed_to?([:create], :host_collections, nil, org)
    end

    def any_readable?(org)
      ::User.allowed_to?(READ_PERM_VERBS, :host_collections, nil, org)
    end

    def list_tags(org_id)
      HostCollection.select('id,name').where(:organization_id => org_id).collect { |m| VirtualTag.new(m.id, m.name) }
    end

    def tags(ids)
      select('id,name').where(:id => ids).collect { |m| VirtualTag.new(m.id, m.name) }
    end

    def list_verbs(global = false)
      {
         :create => _("Administer Host Collections"),
         :read => _("Read Host Collection"),
         :update => _("Modify Host Collection details and content host membership"),
         :delete => _("Delete Host Collection"),
         :read_content_hosts => _("Read Content Hoss in Host Collection"),
         :update_content_hosts => _("Modify Content Hosts in Host Collection"),
         :delete_content_hosts => _("Delete Content Hosts in Host Collection")
      }.with_indifferent_access
    end

    def read_verbs
      [:read]
    end

    def no_tag_verbs
      [:create]
    end

    def items(org, verbs)
      fail "scope requires an organization" if org.nil?
      resource = :host_collections
      if ::User.allowed_all_tags?(verbs, resource, org)
        where(:organization_id => org)
      else
        where("#{HostCollection.table_name}.id in (#{::User.allowed_tags_sql(verbs, resource, org)})")
      end
    end
  end

  included do
    def content_hosts_readable?
      ::User.allowed_to?(SYSTEM_READ_PERMS, :host_collections, self.id, self.organization)
    end

    def content_hosts_deletable?
      ::User.allowed_to?([:delete_content_hosts], :host_collections, self.id, self.organization)
    end

    def content_hosts_editable?
      ::User.allowed_to?([:update_content_hosts], :host_collections, self.id, self.organization)
    end

    def readable?
      ::User.allowed_to?(READ_PERM_VERBS, :host_collections, self.id, self.organization)
    end

    def editable?
      ::User.allowed_to?([:update, :create], :host_collections, self.id, self.organization)
    end

    def deletable?
      ::User.allowed_to?([:delete, :create], :host_collections, self.id, self.organization)
    end
  end

end
end
