module Actions
  module Katello
    module Repository
      class Update < Actions::EntryAction
        middleware.use Actions::Middleware::KeepCurrentUser
        def plan(repository, repo_params)
          action_subject repository
          repository = repository.reload
          repo_params[:url] = nil if repo_params[:url] == ''
          repository.update_attributes!(repo_params)

          if update_content?(repository)
            content_url = ::Katello::Glue::Pulp::Repos.custom_content_path(repository.product, repository.label)
            katello_content_id = repository.product.product_content_by_id(repository.content_id).content_id
            content = ::Katello::Content.find(katello_content_id)

            plan_action(::Actions::Candlepin::Product::ContentUpdate,
                        :owner => repository.organization.label,
                        :content_id => repository.content_id,
                        :name => content.name,
                        :content_url => content_url,
                        :gpg_key_url => repository.yum_gpg_key_url,
                        :label => content.label,
                        :type => repository.content_type,
                        :arches => repository.arch == "noarch" ? nil : repository.arch)

            content.update_attributes!(name: content.name,
                                       content_url: content_url,
                                       content_type: repository.content_type,
                                       label: content.label,
                                       gpg_url: repository.yum_gpg_key_url)

          end

          if SETTINGS[:katello][:use_pulp] && repository.pulp_update_needed?
            plan_action(::Actions::Pulp::Repository::Refresh, repository)
          end

          if SETTINGS[:katello][:use_pulp] && (repository.previous_changes.key?('unprotected') ||
              repository.previous_changes.key?('checksum_type'))
            plan_self(:repository_id => repository.id)
          end
        end

        def run
          repository = ::Katello::Repository.find(input[:repository_id])
          ForemanTasks.async_task(Katello::Repository::MetadataGenerate, repository)
        end

        private

        def update_content?(repository)
          SETTINGS[:katello][:use_cp] &&
            SETTINGS[:katello][:use_pulp] &&
            repository.library_instance? &&
            !repository.product.redhat?
        end
      end
    end
  end
end
