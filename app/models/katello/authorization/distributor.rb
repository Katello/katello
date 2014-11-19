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
  module Authorization::Distributor
    extend ActiveSupport::Concern

    def readable?(user = User.current)
      environment.distributors_readable?(user)
    end

    def editable?(user = User.current)
      environment.distributors_editable?(user)
    end

    def deletable?(user = User.current)
      environment.distributors_deletable?(user)
    end

    module ClassMethods

      def readable(org, user)
        fail "scope requires an organization" if org.nil?
        if org.distributors_readable?(user)
          where(:environment_id => org.kt_environment_ids) #list all distributors in an org
        else #just list for environments the user can access
          where("distributors.environment_id in (#{KTEnvironment.distributors_readable(org, user).select(:id).to_sql})")
        end
      end

      def any_readable?(org, user = User.current)
        org.distributors_readable?(user) ||
            KTEnvironment.distributors_readable(org, user).count > 0
      end

      # TODO: these two functions are somewhat poorly written and need to be redone
      def any_deletable?(env, org, user)
        if env
          env.distributors_deletable?(user)
        else
          org.distributors_deletable?(user)
        end
      end

      def registerable?(env, org, user)
        (env || org).distributors_registerable?(user)
      end
    end

  end
end
