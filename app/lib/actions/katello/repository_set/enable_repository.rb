module Actions
  module Katello
    module RepositorySet
      class EnableRepository < Actions::EntryAction
        def humanized_name
          _("Enable")
        end

        def plan(product, content, options)
          mapper = ::Katello::Candlepin::RepositoryMapper.new(product,
                                                               content,
                                                               options)
          mapper.validate!
          if mapper.find_repository
            fail ::Katello::Errors::ConflictException, _("The repository is already enabled")
          end
          repository = mapper.build_repository
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
