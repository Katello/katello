#
# Katello Organization actions
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.
#

module Authorization::ContentViewDefinition
  READ_PERM_VERBS = [:read, :create, :update, :delete, :publish]
  EDIT_PERM_VERBS = [:create, :update]

  def self.included(base)
    base.extend ClassMethods
  end

  def readable?
    User.allowed_to?(READ_PERM_VERBS, :content_view_definitions, self.id, self.organization)
  end

  def editable?
    User.allowed_to?(EDIT_PERM_VERBS, :content_view_definitions, self.id, self.organization)
  end

  def deletable?
    User.allowed_to?([:delete, :create], :content_view_definitions, self.id, self.organization)
  end

  def publishable?
    User.allowed_to?([:publish], :content_view_definitions, self.id, self.organization)
  end

  module ClassMethods

    def tags(ids)
      select('id,name').where(:id => ids).map do |m|
        VirtualTag.new(m.id, m.name)
      end
    end

    def list_tags(org_id)
      select('id,name').where(:organization_id => org_id).map do |m|
        VirtualTag.new(m.id, m.name)
      end
    end

    def list_verbs(global = false)
      {
        :create  => _("Administer Content View Definitions"),
        :read    => _("Read Content View Definitions"),
        :update  => _("Modify Content View Definitions"),
        :delete  => _("Delete Content View Definitions"),
        :publish => _("Publish Content View Definitions")
      }.with_indifferent_access
    end

    def read_verbs
      [:read]
    end

    def no_tag_verbs
      [:create]
    end

    def any_readable?(org)
      User.allowed_to?(READ_PERM_VERBS, :content_view_definitions, nil, org)
    end

    def readable(org)
      items(org, READ_PERM_VERBS)
    end

    def editable(org)
      items(org, EDIT_PERM_VERBS)
    end

    def creatable?(org)
      User.allowed_to?([:create], :content_view_definitions, nil, org)
    end

    def items(org, verbs)
      raise "scope requires an organization" if org.nil?
      resource = :content_view_definitions
      if User.allowed_all_tags?(verbs, resource, org)
        where(:organization_id => org.id)
      else
        where("content_view_definition_bases.id in (#{User.allowed_tags_sql(verbs, resource, org)})")
      end
    end

  end # end ClassMethods

end