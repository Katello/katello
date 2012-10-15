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



module Authorization::Filter
  READ_PERM_VERBS = [:read, :create, :delete]
  UPDATE_PERM_VERBS = [:create, :update]

  def self.included(base)

    base.class_eval do

      def self.list_tags org_id
        select('id,pulp_id').where(:organization_id=>org_id).collect { |m| VirtualTag.new(m.id, m.pulp_id) }
      end

      def self.tags(ids)
        select('id,pulp_id').where(:id => ids).collect { |m| VirtualTag.new(m.id, m.pulp_id) }
      end

      def self.list_verbs  global = false
        {
           :create => _("Administer Package Filters"),
           :read => _("Read Package Filters"),
           :delete => _("Delete Package Filters"),
           :update => _("Modify Package Filters")
        }.with_indifferent_access
      end

      def self.read_verbs
        [:read]
      end

      def self.no_tag_verbs
        Filter.list_verbs.keys
      end


      def self.creatable? org
        User.allowed_to?([:create], :filters, nil, org)
      end

      def self.any_editable? org
        User.allowed_to?(UPDATE_PERM_VERBS, :filters, nil, org)
      end

      def self.any_readable?(org)
        User.allowed_to?(READ_PERM_VERBS, :filters, nil, org)
      end

      def self.readable_items org
        raise "scope requires an organization" if org.nil?
        resource = :filters
        verbs = READ_PERM_VERBS
        if User.allowed_all_tags?(verbs, resource, org)
           where(:organization_id => org)
        else
          where("filters.id in (#{User.allowed_tags_sql(verbs, resource, org)})")
        end
      end

    end
  end


  def readable?
    User.allowed_to?(READ_PERM_VERBS, :filters, self.id, self.organization)
  end

  def editable?
    User.allowed_to?(UPDATE_PERM_VERBS, :filters, self.id, self.organization)
  end

  def deletable?
     User.allowed_to?([:delete, :create], :filters, self.id, self.organization)
  end


end
