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
      class Update < Actions::EntryAction

        def plan(repository, repo_params)
          repository.disable_auto_reindex!
          action_subject repository
          repository.update_attributes!(repo_params)

          if (::Katello.config.use_cp && ::Katello.config.use_pulp)
            plan_action(::Actions::Candlepin::Product::ContentUpdate,
                        :content_id => repository.content_id,
                        :name => repository.name,
                        :content_url => ::Katello::Glue::Pulp::Repos.custom_content_path(repository.product, repository.label),
                        :gpg_key_url => repository.yum_gpg_key_url,
                        :label => repository.custom_content_label,
                        :type => repository.content_type)
          end

          allowed_changes = %w(url unprotected checksum_type)
          if ::Katello.config.use_pulp && ((repository.previous_changes.key?('name') && repository.docker?) ||
              (allowed_changes & repository.previous_changes.keys).any?)) &&
              !repository.product.provider.redhat_provider?
            plan_action(::Actions::Pulp::Repository::Refresh, repository)
          end

          if ::Katello.config.use_pulp && (repository.previous_changes.key?('unprotected') ||
              repository.previous_changes.key?('checksum_type'))
            plan_self(:user_id => ::User.current.id, :pulp_id => repository.pulp_id,
                      :distributor_type_id => distributor_type_id(repository.content_type))
          end

          plan_action(ElasticSearch::Reindex, repository) if ::Katello.config.use_elasticsearch
        end

        def run
          ::User.current = ::User.find(input[:user_id])
          ForemanTasks.async_task(::Actions::Pulp::Repository::DistributorPublish,
                                  :pulp_id => input[:pulp_id],
                                  :distributor_type_id => input[:distributor_type_id])
        ensure
          ::User.current = nil
        end

        def distributor_type_id(content_type)
          distributor = case content_type
                        when ::Katello::Repository::YUM_TYPE
                          Runcible::Models::YumDistributor
                        when ::Katello::Repository::PUPPET_TYPE
                          Runcible::Models::PuppetInstallDistributor
                        when ::Katello::Repository::FILE_TYPE
                          Runcible::Models::IsoDistributor
                        when ::Katello::Repository::DOCKER_TYPE
                          Runcible::Models::DockerDistributor
                        end
          distributor.type_id
        end

      end
    end
  end
end
