module Actions
  module Katello
    module ContentViewVersion
      class AutoCreateRepositories < Actions::Base
        def plan(import:)
          helper = ::Katello::Pulp3::ContentViewVersion::ImportableRepositories.new(
            organization: import.organization,
            metadata_repositories: import.metadata_map.repositories.select { |r| !r.redhat }
          )
          helper.generate!

          sequence do
            helper.creatable.each do |root|
              plan_action(::Actions::Katello::Repository::CreateRoot, root[:repository])
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
