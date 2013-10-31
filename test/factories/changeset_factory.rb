FactoryGirl.define do
  factory :changeset do
    name "changeset"
    state Katello::Changeset::NEW
  end

  factory :promotion_changeset do
    name "promotion changeset"
    state Katello::Changeset::NEW
    type "Katello::PromotionChangeset"
  end

  factory :deletion_changeset do
    sequence(:name) {|n| "deletion_changeset#{n}"}
    state Katello::Changeset::NEW
    type "Katello::DeletionChangeset"
  end
end
