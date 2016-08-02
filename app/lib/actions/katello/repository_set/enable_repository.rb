module Actions
  module Katello
    module RepositorySet
      class EnableRepository < Actions::EntryAction
        def humanized_name
          _("Enable")
        end

        def plan(product, content, options)
          mapper = repository_mapper(product, content, options, options[:registry_name])
          mapper.validate!
          if mapper.find_repository
            fail ::Katello::Errors::ConflictException, _("The repository is already enabled")
          end
          repository = mapper.build_repository
          plan_action(Repository::Create, repository, false, true)
          action_subject(repository)
        end

        private

        def repository_mapper(product, content, substituions, registry_name)
          if content.type == ::Katello::Repository::CANDLEPIN_DOCKER_TYPE
            ::Katello::Candlepin::Content::DockerRepositoryMapper.new(product,
                                                                content,
                                                                registry_name)

          else
            ::Katello::Candlepin::Content::RepositoryMapper.new(product,
                                                                content,
                                                                substituions)
          end
        end
      end
    end
  end
end
