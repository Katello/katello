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
    module ContentViewPuppetEnvironment
      class Destroy < Actions::EntryAction

        def plan(puppet_env)
          action_subject(puppet_env)
          plan_action(Pulp::Repository::Destroy, pulp_id: puppet_env.pulp_id)
          plan_action(ElasticSearch::Repository::Destroy, pulp_id: puppet_env.pulp_id)
          plan_self
        end

        def finalize
          puppet_env = ::Katello::ContentViewPuppetEnvironment.
            find(input[:content_view_puppet_environment][:id])

          puppet_env.destroy!
        rescue ActiveRecord::RecordNotFound => e
          output[:response] = e.message
        end

        def humanized_name
          _("Delete")
        end
      end
    end
  end
end
