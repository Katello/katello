FactoryBot.define do
  factory :katello_content_view_environment, :class => Katello::ContentViewEnvironment do
    # NOTE: When using this factory, you should provide:
    # - content_view_version: a content view version
    # - environment: the lifecycle environment
    # The content_view will be automatically set from the version

    association :content_view_version, :factory => :katello_content_view_version

    after(:build) do |cve, _evaluator|
      # Set content_view from the version
      if cve.content_view_version && !cve.content_view
        cve.content_view = cve.content_view_version.content_view
      end

      # Set environment to library if not provided
      unless cve.environment
        org = cve.content_view&.organization || cve.content_view_version&.content_view&.organization
        if org
          cve.environment = org.library
        end
      end
    end
  end
end
