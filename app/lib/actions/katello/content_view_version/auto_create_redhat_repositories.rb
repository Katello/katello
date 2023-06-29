module Actions
  module Katello
    module ContentViewVersion
      class AutoCreateRedhatRepositories < Actions::Base
        def plan(import:, path:)
          helper = ::Katello::Pulp3::ContentViewVersion::ImportableRepositories.new(
            organization: import.organization,
            metadata_repositories: import.metadata_map.repositories.select { |r| r.redhat },
            syncable_format: import.metadata_map.syncable_format?,
            path: path
          )
          helper.generate!

          sequence do
            helper.creatable.each do |root|
              plan_action(::Actions::Katello::RepositorySet::EnableRepository,
                            root[:product], root[:content], root[:substitutions],
                            override_url: root[:override_url],
                            override_arch: root[:override_arch])
            end
            helper.updatable.each do |root|
              plan_action(::Actions::Katello::Repository::Update, root[:repository], root[:options])
            end
          end
        end
      end
    end
  end
end
