module Actions
  module Pulp3
    module Orchestration
      module ContentViewVersion
        class CopyVersionUnitsToLibrary < Actions::EntryAction
          def plan(content_view_version)
            concurrence do
              content_view_version.importable_repositories.each do |repo|
                sequence do
                  plan_action(Actions::Pulp3::Repository::CopyContent, repo, SmartProxy.pulp_primary!,
                                                    repo.library_instance,
                                                    copy_all: true,
                                                    mirror: content_view_version.content_view.generated?)
                  plan_action(Actions::Pulp3::Repository::SaveVersion, repo.library_instance)
                  plan_action(Katello::Repository::IndexContent, id: repo.library_instance_id)
                  plan_action(Katello::Repository::MetadataGenerate, repo.library_instance, force_publication: true)
                end
              end
            end
          end
        end
      end
    end
  end
end
