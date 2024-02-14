module Actions
  module Katello
    module ContentViewVersion
      class AutoCreateRedhatRepositories < Actions::Base
        def plan(opts = {})
          helper = ::Katello::Pulp3::ContentViewVersion::ImportableRepositories.new(
            organization: opts[:import].organization,
            metadata_repositories: opts[:import].metadata_map.repositories.select { |r| r.redhat },
            syncable_format: opts[:import].metadata_map.syncable_format?,
            path: opts[:path]
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
