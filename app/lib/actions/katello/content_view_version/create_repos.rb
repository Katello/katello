module Actions
  module Katello
    module ContentViewVersion
      class CreateRepos < Actions::Base
        # allows accessing the build object from the superior action
        attr_accessor :repository_mapping

        def plan(version, source_repositories = [])
          self.repository_mapping = {}
          concurrence do
            source_repositories.each do |repositories|
              new_repository = repositories.first.build_clone(content_view: version.content_view,
                                                             version: version)
              plan_action(Repository::Create, new_repository, clone: true)
              repository_mapping[repositories] = new_repository
            end
          end
        end

        def humanized_name
          _("Create Repositories")
        end
      end
    end
  end
end
