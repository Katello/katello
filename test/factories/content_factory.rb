FactoryBot.define do
  factory :katello_content, :class => Katello::Content do
    sequence(:label) { |n| "content-label#{n}" }
    sequence(:name) { |n| "content-name#{n}" }
  end
end
