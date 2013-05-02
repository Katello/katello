FactoryGirl.define do
  factory :filter do
    sequence(:name) {|n| "Database_filter#{n}" }
    content_view_definition
  end
end
