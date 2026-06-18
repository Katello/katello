FactoryBot.define do
  factory :katello_content_facet, :aliases => [:content_facet], :class => ::Katello::Host::ContentFacet do
    host { association(:host, content_facet: @instance) }

    trait :with_content_view_environment do
      content_view_environments { [association(:katello_content_view_environment)] }
    end

    trait :with_content_source do
      content_source { association(:smart_proxy, :with_pulp3) }
    end

    trait :with_kickstart_repository do
      kickstart_repository { association(:katello_repository, :with_product) }
    end

    trait :with_applicable_errata do
      applicable_errata { [association(:katello_erratum)] }
    end

    trait :with_bound_repositories do
      bound_repositories { [association(:katello_repository)] }
    end
  end
end
