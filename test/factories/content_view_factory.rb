FactoryGirl.define do
  factory :content_view_definition do
    name "Database_definition"
    description "Database content view definition"
    organization
  end

  factory :content_view do
    name "Database"
    description "This content view is for database content"
    organization

    trait :with_definition do
      association :content_view_definition,
        :factory => :content_view_definition
    end

    factory :content_view_with_definition, :traits => [:with_definition]
  end

end
