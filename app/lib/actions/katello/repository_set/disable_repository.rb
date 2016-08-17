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
                                         options,
                                         options[:registry_name]).find_repository
          if repository
            action_subject(repository)
            plan_action(Repository::Destroy, repository, :planned_destroy => true)
          else
            fail ::Katello::Errors::NotFound, _('Repository not found')
          end
        end

        private

        def repository_mapper(product, content, substitutions, registry_name)
          if content.type == ::Katello::Repository::CANDLEPIN_DOCKER_TYPE
            ::Katello::Candlepin::Content::DockerRepositoryMapper.new(product,
                                                                content,
                                                                registry_name)

          else
            ::Katello::Candlepin::Content::RepositoryMapper.new(product,
                                                                content,
                                                                substitutions)
          end
        end
      end
    end
  end
end
