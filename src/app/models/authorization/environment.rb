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



module Authorization::Environment
  extend ActiveSupport::Concern

  CHANGE_SETS_READABLE = [:manage_changesets, :read_changesets, :promote_changesets, :delete_changesets]
  CONTENTS_READABLE = [:read_contents]
  SYSTEMS_READABLE = [:read_systems, :register_systems, :update_systems, :delete_systems]


  module ClassMethods
    def changesets_readable(org)
      authorized_items(org, CHANGE_SETS_READABLE)
    end

    def content_readable(org)
      authorized_items(org, [:read_contents])
    end

    def systems_readable(org)
      if  org.systems_readable?
        where(:organization_id => org)
      else
        authorized_items(org, SYSTEMS_READABLE)
      end
    end

    def systems_registerable(org)
      if org.systems_registerable?
        where(:organization_id => org)
      else
        authorized_items(org, [:register_systems])
      end
    end

    def any_viewable_for_promotions?(org)
      return false if !Katello.config.katello?
      User.allowed_to?(CHANGE_SETS_READABLE + CONTENTS_READABLE, :environments, org.environment_ids, org, true)
    end

    def any_contents_readable? org, skip_library=false
      ids = org.environment_ids
      ids = ids - [org.library.id] if skip_library
      User.allowed_to?(CONTENTS_READABLE, :environments, ids, org, true)
    end

    def authorized_items org, verbs, resource = :environments
      raise "scope requires an organization" if org.nil?
      if User.allowed_all_tags?(verbs, resource, org)
         where(:organization_id => org)
      else
        where("environments.id in (#{User.allowed_tags_sql(verbs, resource, org)})")
      end
    end

    def list_verbs global = false
      if Katello.config.katello?
        {
        :read_contents => _("Read Environment Contents"),
        :read_systems => _("Read Systems in Environment"),
        :register_systems =>_("Register Systems in Environment"),
        :update_systems => _("Modify Systems in Environment"),
        :delete_systems => _("Remove Systems in Environment"),
        :read_changesets => _("Read Changesets in Environment"),
        :manage_changesets => _("Administer Changesets in Environment"),
        :promote_changesets => _("Promote Content to Environment"),
        :delete_changesets => _("Delete Content from Environment")
        }.with_indifferent_access
      else
        {
        :read_contents => _("Read Environment Contents"),
        :read_systems => _("Read Systems in Environment"),
        :register_systems =>_("Register Systems in Environment"),
        :update_systems => _("Modify Systems in Environment"),
        :delete_systems => _("Remove Systems in Environment"),
        }.with_indifferent_access
      end
    end

    def read_verbs
      if Katello.config.katello?
        [:read_contents, :read_changesets, :read_systems]
      else
        [:read_contents, :read_systems]
      end
    end
  end


  module InstanceMethods
    def viewable_for_promotions?
      return false if !Katello.config.katello?
      User.allowed_to?(CHANGE_SETS_READABLE + CONTENTS_READABLE, :environments, self.id, self.organization)
    end

    def any_operation_readable?
      return false if !Katello.config.katello?
      User.allowed_to?(self.class.list_verbs.keys, :environments, self.id, self.organization) ||
          self.organization.systems_readable? || self.organization.any_systems_registerable? ||
          ActivationKey.readable?(self.organization)
    end

    def changesets_promotable?
      return false if !Katello.config.katello?
      User.allowed_to?([:promote_changesets], :environments, self.id,
                                self.organization)
    end

    def changesets_deletable?
      return false if !Katello.config.katello?
      User.allowed_to?([:delete_changesets], :environments, self.id,
                                self.organization)
    end

    def changesets_readable?
      return false if !Katello.config.katello?
      User.allowed_to?(CHANGE_SETS_READABLE, :environments,
                                self.id, self.organization)
    end

    def changesets_manageable?
      return false if !Katello.config.katello?
      User.allowed_to?([:manage_changesets], :environments, self.id,
                                self.organization)
    end

    def contents_readable?
      return false if !Katello.config.katello?
      User.allowed_to?(CONTENTS_READABLE, :environments, self.id,
                                self.organization)
    end

    def systems_readable?
      self.organization.systems_readable? ||
          User.allowed_to?(SYSTEMS_READABLE, :environments, self.id, self.organization)
    end

    def systems_editable?
      User.allowed_to?([:update_systems], :organizations, nil, self.organization) ||
          User.allowed_to?([:update_systems], :environments, self.id, self.organization)
    end

    def systems_deletable?
      User.allowed_to?([:delete_systems], :organizations, nil, self.organization) ||
          User.allowed_to?([:delete_systems], :environments, self.id, self.organization)
    end

    def systems_registerable?
      self.organization.systems_registerable? ||
          User.allowed_to?([:register_systems], :environments, self.id, self.organization)
    end
  end

end
