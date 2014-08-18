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
  module Pulp
    module Repository
      class Refresh < Pulp::Abstract

        def plan(repository)
          plan_action(::Actions::Pulp::Repository::UpdateImporter,
                      :repo_id => repository.pulp_id,
                      :id => repository.importers.first['id'],
                      :config => repository.generate_importer.config
                      )
          existing_distributors = repository.distributors
          concurrence do
            repository.generate_distributors.each do |distributor|
              found = existing_distributors.find{ |i| i['distributor_type_id'] == distributor.type_id }
              if found
                plan_action(::Actions::Pulp::Repository::RefreshDistributor,
                            :repo_id => repository.pulp_id,
                            :id => found['id'],
                            :config => distributor.config
                            )
              else
                plan_action(::Actions::Pulp::Repository::AssociateDistributor,
                            :repo_id => repository.pulp_id,
                            :type_id => distributor.type_id,
                            :config => distributor.config,
                            :hash => { :distributor_id => distributor.id }
                            )
              end
            end
          end

        end
      end
    end
  end
end
