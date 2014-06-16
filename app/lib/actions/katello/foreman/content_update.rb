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
    module Foreman
      class ContentUpdate < Actions::Katello::Foreman::Abstract
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(environment, content_view)
          plan_self(environment_id: environment.id,
                    content_view_id: content_view.id)
        end

        input_format do
          param :environment_id
          param :content_view_id
        end

        def finalize
          environment  = ::Katello::KTEnvironment.find(input[:environment_id])
          content_view = ::Katello::ContentView.find(input[:content_view_id])
          ::Katello::Foreman.update_puppet_environment(content_view, environment)

          content_view.version(environment).repos(environment).each do |repo|
            if distribution = repo.bootable_distribution
              ::Redhat.find_or_create_operating_system(distribution)
              os = Redhat.find_or_create_operating_system(distribution)

              arch = Architecture.where(:name => distribution.arch).first_or_create!
              os.architectures << arch unless os.architectures.include?(arch)
            end
          end
        end
      end
    end
  end
end
