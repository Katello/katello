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
      class MetadataGenerate < Actions::Base

        def plan(repository, source_repository = nil, dependency = nil)
          plan_action(Pulp::Repository::DistributorPublish,
                      pulp_id: repository.pulp_id,
                      distributor_type_id: distributor_class(repository, !!source_repository).type_id,
                      source_pulp_id: source_repository.try(:pulp_id),
                      dependency: dependency)
        end

        def distributor_class(repository, clone)
          case repository.content_type
          when ::Katello::Repository::YUM_TYPE
            if clone
              Runcible::Models::YumCloneDistributor
            else
              Runcible::Models::YumDistributor
            end
          when ::Katello::Repository::PUPPET_TYPE
            Runcible::Models::PuppetInstallDistributor
          when ::Katello::Repository::FILE_TYPE
            Runcible::Models::IsoDistributor
          end
        end

      end
    end
  end
end
