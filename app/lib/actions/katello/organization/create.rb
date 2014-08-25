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
    module Organization
      class Create < Actions::EntryAction

        def plan(organization)
          organization.setup_label_from_name
          organization.create_library
          organization.create_anonymous_provider
          organization.create_redhat_provider
          cp_create = nil

          organization.save!

          sequence do
            if ::Katello.config.use_cp
              cp_create = plan_action(Candlepin::Owner::Create,
                                      label:  organization.label,
                                      name: organization.name)
            end
            plan_action(Environment::LibraryCreate, organization.library)
          end
          if cp_create
            action_subject organization, label: cp_create.output[:response][:key]
          else
            action_subject organization
          end
          plan_self
        end

        def humanized_name
          _("Create")
        end
      end
    end
  end
end
