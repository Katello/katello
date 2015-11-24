FactoryGirl.modify do
  factory :host do
    transient do
      content_view nil
      lifecycle_environment nil
    end

    trait :with_content do
      association :content_facet, :factory => :content_facet, :strategy => :build

      after(:build) do |host, evaluator|
        if host.content_facet
          host.content_facet.content_view = evaluator.content_view if evaluator.content_view
          host.content_facet.lifecycle_environment = evaluator.lifecycle_environment if evaluator.lifecycle_environment
        end
      end
    end

    trait :with_subscription do
      association :subscription_facet, :factory => :subscription_facet, :strategy => :build
    end
  end
end
