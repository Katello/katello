FactoryBot.define do
  factory :katello_content_view_package_filter_rule,
          :class => Katello::ContentViewPackageFilterRule do
    sequence(:name) { |n| "package #{n}" }
    association :filter, :factory => :katello_content_view_package_filter
  end

  factory :katello_content_view_package_group_filter_rule,
          :class => Katello::ContentViewPackageGroupFilterRule do
    sequence(:name) { |n| "package group #{n}" }
    sequence(:uuid) { |n| "3805853f-5cae-4a4a-8549-0ec86410f#{n}" }
    association :filter, :factory => :katello_content_view_package_group_filter
  end

  factory :katello_content_view_erratum_filter_rule,
          :class => Katello::ContentViewErratumFilterRule do
    association :filter, :factory => :katello_content_view_erratum_filter
  end

  factory :katello_content_view_docker_filter_rule,
          :class => Katello::ContentViewDockerFilterRule do
    sequence(:name) { |n| "docker #{n}" }
    association :filter, :factory => :katello_content_view_docker_filter
  end

  factory :katello_content_view_module_stream_filter_rule,
          :class => Katello::ContentViewModuleStreamFilterRule do
    association :filter, :factory => :katello_content_view_module_stream_filter
  end

  factory :katello_content_view_deb_filter_rule,
          :class => Katello::ContentViewDebFilterRule do
    sequence(:name) { |n| "deb #{n}" }
    association :filter, :factory => :katello_content_view_deb_filter
  end
end
