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

module Authorization::Distributor
  extend ActiveSupport::Concern

  module ClassMethods
    # returns list of virtual permission tags for the current user
    def list_tags
      select('id,name').all.collect { |m| VirtualTag.new(m.id, m.name) }
    end

    def readable(org)
      raise "scope requires an organization" if org.nil?
      if org.distributors_readable?
        where(:environment_id => org.environment_ids) #list all distributors in an org
      else #just list for environments the user can access
        where("distributors.environment_id in (#{::KTEnvironment.distributors_readable(org).select(:id).to_sql})")
      end
    end

    def any_readable?(org)
      org.distributors_readable? ||
           ::KTEnvironment.distributors_readable(org).count > 0
    end

    # TODO: these two functions are somewhat poorly written and need to be redone
    def any_deletable?(env, org)
      if env
        env.distributors_deletable?
      else
        org.distributors_deletable?
      end
    end

    def registerable?(env, org, content_view = nil)
      subscribable = content_view ? content_view.subscribable? : true
      registerable = (env || org).distributors_registerable?
      subscribable && registerable
    end
  end

  included do
    def readable?
      environment.distributors_readable?
    end

    def editable?
      environment.distributors_editable?
    end

    def deletable?
      environment.distributors_deletable?
    end
  end

end
