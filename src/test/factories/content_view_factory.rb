FactoryGirl.define do
  factory :content_view do
    sequence(:name) { |n| "Database#{n}" }
    description "This content view is for database content"
    organization

    trait :with_definition do
      association :content_view_definition,
        :factory => :content_view_definition
    end

    factory :content_view_with_definition, :traits => [:with_definition]
  end

end
