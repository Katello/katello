FactoryBot.define do
  factory :katello_content_view_filter, :class => Katello::ContentViewFilter do
    sequence(:name) { |n| "Database_filter#{n}" }
    association :content_view, :factory => :katello_content_view
  end

  factory :katello_content_view_package_filter,
          :class => Katello::ContentViewPackageFilter,
          :parent => :katello_content_view_filter do
  end

  factory :katello_content_view_erratum_filter,
          :class => Katello::ContentViewErratumFilter,
          :parent => :katello_content_view_filter do
  end

  factory :katello_content_view_module_stream_filter,
          :class => Katello::ContentViewModuleStreamFilter,
          :parent => :katello_content_view_filter do
  end

  factory :katello_content_view_package_group_filter,
          :class => Katello::ContentViewPackageGroupFilter,
          :parent => :katello_content_view_filter do
  end

  factory :katello_content_view_docker_filter,
          :class => Katello::ContentViewDockerFilter,
          :parent => :katello_content_view_filter do
  end
  factory :katello_content_view_deb_filter,
          :class => Katello::ContentViewDebFilter,
          :parent => :katello_content_view_filter do
  end
end
