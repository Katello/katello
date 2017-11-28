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

            if new_repository.link?
              fail "Cannot clone metadata if more than one repository" if repositories.count > 1
              plan_action(Repository::CloneYumMetadata, repositories[0], new_repository,
                                                            :force_yum_metadata_regeneration => true)
            else
              if new_repository.yum?
                repositories.each do |repository|
                  plan_action(Repository::CloneYumContent, repository, new_repository, filters, !incremental,
                              :generate_metadata => !incremental, :index_content => !incremental, :simple_clone => incremental)
                end
              elsif new_repository.docker?
                plan_action(Repository::CloneDockerContent, repository, new_repository, filters)
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
