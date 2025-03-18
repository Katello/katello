FactoryBot.define do
  factory :structured_apt_katello_repository, :class => Katello::Repository do
    association :root, :factory => :katello_root_repository, :trait => :structured_apt_deb_root, :strategy => :build

    sequence(:pulp_id) { |n| "pulp-#{n}" }
    sequence(:relative_path) { |n| "/ACME_Corporation/DEV/Repo#{n}" }

    content_id { 'struct-apt-content-id' }
  end
end
