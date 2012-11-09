FactoryGirl.define do
  factory :repository do
    sequence(:name) { |n| "Repo#{n}" }
    sequence(:pulp_id) { |n| "pulp-#{n}" }
    sequence(:content_id)

    ignore do
      stubbed = true
    end

    trait :fedora_17_el6 do
      name          "Fedora 17 el6"
      label         "fedora_17_el6_label"
      pulp_id       "Fedora_17_el6"
      content_id    "450"
    end

    trait :fedora_17_x86_64_dev do
      name          "Fedora 17"
      label         "fedora_17_dev_label"
      pulp_id       "2"
      content_id    "1"
    end

  end
end
