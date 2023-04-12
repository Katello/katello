FactoryBot.define do
  factory :katello_product_content, :class => Katello::ProductContent do
    association :product, :factory => :katello_product, :strategy => :build
    enabled { false }
  end
end
