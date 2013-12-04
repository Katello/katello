FactoryGirl.define do
  factory :changeset, :class => Katello::Changeset do
    name "changeset"
    state Katello::Changeset::NEW
  end

  factory :promotion_changeset, :class => Katello::PromotionChangeset do
    name "promotion changeset"
    state Katello::Changeset::NEW
    type "Katello::PromotionChangeset"
  end

  factory :deletion_changeset, :class => Katello::DeletionChangeset do
    sequence(:name) {|n| "deletion_changeset#{n}"}
    state Katello::Changeset::NEW
    type "Katello::DeletionChangeset"
  end
end
