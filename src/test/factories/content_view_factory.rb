FactoryGirl.define do
  factory :content_view do
    sequence(:name) { |n| "Database#{n}" }
    description "This content view is for database content"
    organization

    trait :with_definition do
      association :content_view_definition,
        :factory => :content_view_definition
    end

    trait :with_environment do
      after_build do |cv|
        FactoryGirl.build_list(:content_view_environment, 2, :content_view => cv)
      end
    end

    factory :content_view_with_definition, :traits => [:with_definition]
    factory :content_view_with_environment, :traits => [:with_environment]
  end
end
