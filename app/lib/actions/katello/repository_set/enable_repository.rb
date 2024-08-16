module Actions
  module Katello
    module RepositorySet
      class EnableRepository < Actions::EntryAction
        def humanized_name
          _("Enable")
        end

        def plan(product, content, substitutions, opts = {})
          mapper = ::Katello::Candlepin::RepositoryMapper.new(product,
                                                               content,
                                                               substitutions)
          mapper.validate!
          if mapper.find_repository
            fail ::Katello::Errors::ConflictException, _("The repository is already enabled")
          end
          repository = mapper.build_repository
          repository.root.arch = opts[:override_arch] if opts[:override_arch].present?
          if opts[:override_url]
            repository.root.url = opts[:override_url]
            repository.root.download_policy = ::Katello::RootRepository::DOWNLOAD_IMMEDIATE if URI(opts[:override_url]).scheme == 'file'
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
            :content_type => repo.content_type,
          }
        end
      end
    end
  end
end
