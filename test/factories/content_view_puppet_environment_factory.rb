FactoryBot.define do
  factory :katello_content_view_puppet_environment, :class => Katello::ContentViewPuppetEnvironment do
    sequence(:name) { |n| "Content View Puppet Environment #{n}" }
    sequence(:pulp_id) { |n| "pulp-#{n}" }
    association :puppet_environment, :factory => :environment
    association :environment, :factory => :katello_k_t_environment
    association :content_view_version, :factory => :katello_content_view_version

    trait :library_content_view_puppet_environment do
      name { "Library View Puppet Environment" }
      pulp_id { "library-view" }
    end
  end
end
