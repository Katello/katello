module Actions
  module Katello
    module Repository
      class Update < Actions::EntryAction
        def plan(root, repo_params)
          repository = root.library_instance
          action_subject root.library_instance

          repo_params[:url] = nil if repo_params[:url] == ''
          root.update_attributes!(repo_params)

          if update_content?(repository)
            content = root.content

            plan_action(::Actions::Candlepin::Product::ContentUpdate,
                        :owner => repository.organization.label,
                        :content_id => root.content_id,
                        :name => content.name,
                        :content_url => root.custom_content_path,
                        :gpg_key_url => repository.yum_gpg_key_url,
                        :label => content.label,
                        :type => root.content_type,
                        :arches => root.arch == "noarch" ? nil : root.arch)

            content.update_attributes!(name: content.name,
                                       content_url: root.custom_content_path,
                                       content_type: repository.content_type,
                                       label: content.label,
                                       gpg_url: repository.yum_gpg_key_url)
          end
          if root.pulp_update_needed?
            plan_action(PulpSelector,
                        [::Actions::Pulp::Repository::Refresh,
                        Pulp3::Orchestration::Repository::Update],
                        repository, SmartProxy.pulp_master)
          end

          plan_self(:repository_id => root.library_instance.id)
        end

        def run
          repository = ::Katello::Repository.find(input[:repository_id])
          ForemanTasks.async_task(Katello::Repository::MetadataGenerate, repository)
        end

        private

        def update_content?(repository)
          repository.library_instance? && !repository.product.redhat?
        end
      end
    end
  end
end
