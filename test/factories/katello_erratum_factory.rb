FactoryBot.define do
  factory :katello_erratum, class: Katello::Erratum do
    sequence(:pulp_id) { |n| n }
  end
end
