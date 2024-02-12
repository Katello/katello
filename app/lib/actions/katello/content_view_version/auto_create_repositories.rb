module Actions
  module Katello
    module ContentViewVersion
      class AutoCreateRepositories < Actions::Base
        def plan(opts = {})
          helper = ::Katello::Pulp3::ContentViewVersion::ImportableRepositories.new(
            organization: opts[:import].organization,
            metadata_repositories: opts[:import].metadata_map.repositories.select { |r| !r.redhat },
            syncable_format: opts[:import].metadata_map.syncable_format?,
            path: opts[:path]
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
