FactoryGirl.define do
  factory :katello_user, :class => "User" do
    sequence(:mail) { |n| "user#{n}@katello.org" }

    trait :batman do
      login "batman"
      password "ihaveaterriblepassword"
      mail "batman@wayne.ent.com"
    end
  end
end
