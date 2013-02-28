FactoryGirl.define do
  factory :system_template_distribution do

    sequence(:distribution_pulp_id) { |n| "pulpid#{n}" }

  end
end
