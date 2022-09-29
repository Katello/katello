FactoryBot.modify do
  factory :host do
    transient do
      content_view { nil }
      lifecycle_environment { nil }
      content_source { nil }
    end

    trait :with_content do
      association :content_facet, :factory => :content_facet, :strategy => :build

      after(:build) do |host, evaluator|
        if host.content_facet
          if evaluator.content_view && evaluator.lifecycle_environment
            host.content_facet.assign_single_environment(
              content_view_id: evaluator.content_view.id,
              lifecycle_environment_id: evaluator.lifecycle_environment.id
            )
          end
          host.content_facet.content_source = evaluator.content_source if evaluator.content_source
        end
      end
    end

    trait :with_subscription do
      association :subscription_facet, :factory => :subscription_facet, :strategy => :build
    end
  end
end
