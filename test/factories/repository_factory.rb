FactoryGirl.define do
  factory :repository do

    trait :fedora_17_x86_64 do
      name          "Fedora 17 x86_64"
      label         "fedora_17_x86_64_label"
      pulp_id       "Fedora 17 x86_64"
      content_id    "1"
      association   :environment_product
      #gpg_key:              fedora_gpg_key
    end

    trait :fedora_17_x86_64_dev do
      name          "Fedora 17"
      label         "fedora_17_dev_label"
      pulp_id       "2"
      content_id    "1"
      association   :environment_product
      association   :library_instance
      #gpg_key:              fedora_gpg_key
      #library_instance:     fedora_17
    end

  end
end
