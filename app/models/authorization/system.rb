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

module Authorization::System
  extend ActiveSupport::Concern

  module ClassMethods
    # returns list of virtual permission tags for the current user
    def list_tags
      select('id,name').all.collect { |m| VirtualTag.new(m.id, m.name) }
    end

    def readable(org)
      raise "scope requires an organization" if org.nil?
      if org.systems_readable?
        where(:environment_id => org.environment_ids) #list all systems in an org
      else #just list for environments the user can access
        where_clause = "systems.environment_id in (#{::KTEnvironment.systems_readable(org).select(:id).to_sql})"
        where_clause += " or "
        where_clause += "system_system_groups.system_group_id in (#{::SystemGroup.systems_readable(org).select(:id).to_sql})"
        joins("left outer join system_system_groups on systems.id =
                                    system_system_groups.system_id").where(where_clause)
      end
    end

    def any_readable?(org)
      org.systems_readable? ||
        ::KTEnvironment.systems_readable(org).count > 0 ||
        ::SystemGroup.systems_readable(org).count > 0
    end

    # TODO: these two functions are somewhat poorly written and need to be redone
    def any_deletable?(env, org)
      if env
        env.systems_deletable? || org.system_groups.any?{|g| g.systems_deletable?}
      else
        org.systems_deletable? || org.system_groups.any?{|g| g.systems_deletable?}
      end
    end

    def registerable?(env, org, content_view = nil)
      subscribable = content_view ? content_view.subscribable? : true
      registerable = (env || org).systems_registerable?
      subscribable && registerable
    end
  end

  included do
    def readable?
      sg_readable = false
      sg_readable = !::SystemGroup.systems_readable(self.organization).where(:id=>self.system_group_ids).empty?
      environment.systems_readable? || sg_readable
    end

    def editable?
      sg_editable = false
      sg_editable = !::SystemGroup.systems_editable(self.organization).where(:id=>self.system_group_ids).empty?
      environment.systems_editable? || sg_editable
    end

    def deletable?
      sg_deletable = false
      sg_deletable = !::SystemGroup.systems_deletable(self.organization).where(:id=>self.system_group_ids).empty?
      environment.systems_deletable? || sg_deletable
    end
  end

end
