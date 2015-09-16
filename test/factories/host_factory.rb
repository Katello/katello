FactoryGirl.modify do
  factory :host do
    transient do
      content_view nil
      lifecycle_environment nil
    end

    trait :with_content do
      association :content_aspect, :factory => :content_aspect, :strategy => :build

      after(:build) do |host, evaluator|
        if host.content_aspect
          host.content_aspect.content_view = evaluator.content_view if evaluator.content_view
          host.content_aspect.lifecycle_environment = evaluator.lifecycle_environment if evaluator.lifecycle_environment
        end
      end
    end

    trait :with_subscription do
      association :subscription_aspect, :factory => :subscription_aspect, :strategy => :build
    end
  end
end
