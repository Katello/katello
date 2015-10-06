FactoryGirl.define do
  factory :katello_content_aspects, :aliases => [:content_aspect], :class => ::Katello::Host::ContentAspect do
    sequence(:uuid) { |n| "uuid-#{n}" }
  end
end
