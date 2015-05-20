module Actions
  module Katello
    module Repository
      class Update < Actions::EntryAction
        def plan(repository, repo_params)
          repository.disable_auto_reindex!
          action_subject repository
          ostree_branches = repo_params.delete(:ostree_branches)
          if ostree_branches
            # remove the ostree_branches not in this list
            repository.ostree_branches.keep_if do |branch|
              ostree_branches.include?(branch.name)
            end

            # add the new ostree_branches
            (ostree_branches - repository.ostree_branch_names).each do |ref|
              repository.ostree_branches.create!(:name => ref)
            end
          end
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

          if ::Katello.config.use_pulp && repository.pulp_update_needed?
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
                        when ::Katello::Repository::OSTREE_TYPE
                          Runcible::Models::OstreeDistributor
                        end
          distributor.type_id
        end
      end
    end
  end
end
