FactoryGirl.define do
  factory :katello_repository, :class => Katello::Repository do
    sequence(:name) { |n| "Repo #{n}" }
    sequence(:label) { |n| "repo_#{n}" }
    sequence(:pulp_id) { |n| "pulp-#{n}" }
    sequence(:content_id)
    sequence(:relative_path) { |n| "/ACME_Corporation/DEV/Repo#{n}" }
    url "http://localhost/foo"

    trait :fedora_17_el6 do
      name "Fedora 17 el6"
      label "fedora_17_el6_label"
      pulp_id "Fedora_17_el6"
      content_id "450"
      relative_path "/ACME_Corporation/Library/fedora_17_el6_label"
    end

    trait :fedora_17_x86_64_dev do
      name "Fedora 17"
      label "fedora_17_dev_label"
      pulp_id "2"
      content_id "1"
      relative_path "/ACME_Corporation/DEV/fedora_17_el6_label"
    end

    trait :docker do
      content_type "docker"
      name "dockeruser/repo"
      label "dockeruser_repo"
      relative_path "empty_organization-fedora_label-dockeruser_repo"
    end

    trait :puppet do
      content_type "puppet"
    end

    trait :iso do
      content_type "file"
    end
  end
end
