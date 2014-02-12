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
  module Headpin
    module System
      class Create < Actions::EntryAction

        middleware.use ::Actions::Middleware::RemoteAction

        def plan(system)
          system.disable_auto_reindex!
          cp_create = plan_action(Candlepin::Consumer::Create,
                                  cp_environment_id:   system.cp_environment_id,
                                  organization_label:  system.organization.label,
                                  name:                system.name,
                                  cp_type:             system.cp_type,
                                  facts:               system.facts,
                                  installed_products:  system.installedProducts,
                                  autoheal:            system.autoheal,
                                  release_ver:         system.release,
                                  service_level:       system.serviceLevel,
                                  uuid:                "",
                                  capabiliteis:        system.capabilities)
          system.save!
          action_subject system, uuid: cp_create.output[:response][:uuid]
          plan_action ElasticSearch::Reindex, system
        end

        def humanized_name
          _("Create")
        end

        def finalize
          system = ::Katello::System.find(input[:system][:id])
          system.disable_auto_reindex!
          system.uuid = input[:uuid]
          system.save!
        end
      end
    end
  end
end
