FactoryBot.define do
  factory :katello_event, class: Katello::Event do
    trait :in_progress do
      in_progress { true }
    end
  end
end
