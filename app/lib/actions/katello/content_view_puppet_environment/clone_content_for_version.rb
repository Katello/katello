module Actions
  module Katello
    module ContentViewPuppetEnvironment
      class CloneContentForVersion < Actions::Base
        def plan(puppet_environment, modules_by_repoid)
          sequence do
            concurrence do
              modules_by_repoid.each_pair do |repo_id, modules|
                source_repo = ::Katello::Repository.find(repo_id)

                plan_action(Pulp::ContentViewPuppetEnvironment::CopyContents, puppet_environment,
                            puppet_modules: modules, source_repository_id: source_repo.id)
              end
            end
          end
        end
      end
    end
  end
end
