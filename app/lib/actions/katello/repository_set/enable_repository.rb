module Actions
  module Katello
    module RepositorySet
      class EnableRepository < Actions::EntryAction
        def humanized_name
          _("Enable")
        end

        def plan(product, content, substitutions, override_url: nil,
                 override_arch: nil)
          mapper = ::Katello::Candlepin::RepositoryMapper.new(product,
                                                               content,
                                                               substitutions)
          mapper.validate!
          if mapper.find_repository
            fail ::Katello::Errors::ConflictException, _("The repository is already enabled")
          end
          repository = mapper.build_repository
          repository.root.arch = override_arch if override_arch.present?
          if override_url
            repository.root.url = override_url
            repository.root.download_policy = ::Katello::RootRepository::DOWNLOAD_IMMEDIATE if URI(override_url).scheme == 'file'
          end
          plan_action(Repository::Create, repository, clone: false)
          action_subject(repository)
          plan_self
        end

        def run
          repo = ::Katello::Repository.find(input[:repository][:id])
          output[:repository] = {
            :name => repo.name,
            :id => repo.id,
            :content_type => repo.content_type
          }
        end
      end
    end
  end
end
