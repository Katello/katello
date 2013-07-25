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

module Authorization::ContentView
  READ_PERM_VERBS = [:read, :promote, :subscribe]

  def self.included(base)
    base.extend ClassMethods
  end

  def readable?
    User.allowed_to?(READ_PERM_VERBS, :content_views, self.id, self.organization)
  end

  def promotable?
    User.allowed_to?([:promote], :content_views, self.id, self.organization)
  end

  def subscribable?
    User.allowed_to?([:subscribe], :content_views, self.id, self.organization)
  end

  module ClassMethods

    def tags(ids)
      select('id, name').where(:id => ids).map do |v|
        VirtualTag.new(v.id, v.name)
      end
    end

    def list_tags(org_id)
      select('id, name').where(:organization_id => org_id).map do |v|
        VirtualTag.new(v.id, v.name)
      end
    end

    def list_verbs(global = false)
      {
        :read => _("Read Content Views"),
        :promote => _("Promote Content Views"),
        :subscribe => _("Subscribe Systems To Content Views")
      }.with_indifferent_access
    end

    def read_verbs
      [:read]
    end

    def no_tag_verbs
      []
    end

    def any_readable?(org)
      User.allowed_to?(READ_PERM_VERBS, :content_views, nil, org)
    end

    def readable(org)
      items(org, READ_PERM_VERBS)
    end

    def promotable(org)
      items(org, [:promote])
    end

    def subscribable(org)
      items(org, [:subscribe])
    end

    def items(org, verbs)
      raise "scope requires an organization" if org.nil?
      resource = :content_views

      if Katello.config.katello?
        if User.allowed_all_tags?(verbs, resource, org)
          where(:organization_id => org.id)
        else
          where("content_views.id in (#{User.allowed_tags_sql(verbs, resource, org)})")
        end
      else
        where("0 = 1")
      end
    end
  end
end
