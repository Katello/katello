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

module Actions
  module Katello
    module Repository
      class CorrectChecksum < Actions::Base
        def plan(repo)
          plan_self(:repo_id => repo.id)
        end

        def finalize
          ::User.current = ::User.anonymous_admin
          repo = ::Katello::Repository.find(input[:repo_id])
          found_checksum = repo.pulp_checksum_type

          if found_checksum && repo.checksum_type != found_checksum
            repo.checksum_type = found_checksum
            repo.save!
          end
        ensure
          ::User.current = nil
        end
      end
    end
  end
end
