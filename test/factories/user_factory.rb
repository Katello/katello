FactoryGirl.define do
  factory :user do
    sequence(:login) { |n| "user#{n}" }
    sequence(:mail) { |n| "user#{n}@katello.org" }
    password "password1"
    sequence(:remote_id) { |n| "remote#{n}" }

    trait :batman do
      login "batman"
      password "ihaveaterriblepassword"
      mail "batman@wayne.ent.com"
      remote_id "batman"
    end

  end
end
