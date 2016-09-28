module Actions
  module Katello
    module Repository
      class CloneToVersion < Actions::Base
        # allows accessing the build object from the superior action
        attr_accessor :new_repository

        def plan(repositories, content_view_version, incremental = false)
          content_view = content_view_version.content_view
          filters = incremental ? [] : content_view.filters.applicable(repositories.first)

          self.new_repository = repositories.first.build_clone(content_view: content_view,
                                                               version: content_view_version)

          sequence do
            plan_action(Repository::Create, new_repository, true, false)

            repositories.each do |repository|
              if new_repository.yum?
                plan_action(Repository::CloneYumContent, repository, new_repository, filters, !incremental,
                            :generate_metadata => !incremental, :index_content => !incremental, :simple_clone => incremental)
              elsif new_repository.docker?
                plan_action(Repository::CloneDockerContent, repository, new_repository)
              elsif new_repository.ostree?
                plan_action(Repository::CloneOstreeContent, repository, new_repository)
              elsif new_repository.file?
                plan_action(Repository::CloneFileContent, repository, new_repository)
              end
            end
          end
        end
      end
    end
  end
end
