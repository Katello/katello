FactoryGirl.define do
  factory :katello_role, :class => Katello::Role do

    factory :katello_administrator do
      name        "ADMINISTRATOR"
      description "Super administrator with all access."
      locked      true
    end

  end
end
