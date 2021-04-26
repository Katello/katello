module Actions
  module Katello
    module ContentViewVersion
      class AutoCreateRepositories < Actions::Base
        def plan(organization:, metadata:)
          helper = ::Katello::Pulp3::ContentViewVersion::ImportableRepositories.
                      new(organization: organization,
                          metadata: metadata)
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
