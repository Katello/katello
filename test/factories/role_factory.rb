FactoryGirl.define do
  factory :role, :class => Katello::Role do

    factory :administrator do
      name        "ADMINISTRATOR"
      description "Super administrator with all access."
      locked      true
    end

  end
end
