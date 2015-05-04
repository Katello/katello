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
    module ContentView
      class CapsuleGenerateAndSync < Actions::Base
        def humanized_name
          _("Generate Capsule Metadata and Sync")
        end

        def plan(content_view, environment)
          sequence do
            plan_action(NodeMetadataGenerate, content_view, environment)

            concurrence do
              ::Katello::CapsuleContent.with_environment(environment).each do |capsule_content|
                plan_action(Katello::CapsuleContent::Sync, capsule_content, :content_view => content_view,
                            :environment => environment)
              end
            end
          end
        end
      end
    end
  end
end
