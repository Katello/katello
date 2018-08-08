module Actions
  module Katello
    module RepositorySet
      class DisableRepository < Actions::EntryAction
        def humanized_name
          _("Disable")
        end

        def plan(product, content, options)
          repository = repository_mapper(product,
                                         content,
                                         options).find_repository
          if repository
            action_subject(repository)
            plan_action(Repository::Destroy, repository, :planned_destroy => true)
          else
            fail ::Katello::Errors::NotFound, _('Repository not found')
          end
        end

        private

        def repository_mapper(product, content, substitutions)
          ::Katello::Candlepin::RepositoryMapper.new(product,
                                                     content,
                                                     substitutions)
        end
      end
    end
  end
end
