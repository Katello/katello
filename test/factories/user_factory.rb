FactoryGirl.define do
  factory :katello_user, :class => "User" do
    sequence(:mail) { |n| "user#{n}@katello.org" }
    sequence(:remote_id) { |n| "remote#{n}" }

    trait :batman do
      login "batman"
      password "ihaveaterriblepassword"
      mail "batman@wayne.ent.com"
      remote_id "batman"
    end
  end
end
