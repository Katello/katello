FactoryGirl.define do
  factory :content_view_environment do
    sequence(:name) { |n| "Database#{n}" }
    sequence(:cp_id) { |n| "#{n}-123" }
    sequence(:label) { |n| "Label#{n}" }
    content_view
  end
end