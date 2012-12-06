FactoryGirl.define do
  factory :changeset do
    name "changeset"
    state Changeset::NEW
  end

  factory :promotion_changeset do
    name "promotion changeset"
    state Changeset::NEW
    type "PromotionChangeset"
  end

  factory :deletion_changeset do
    sequence(:name) {|n| "deletion_changeset#{n}"}
    state Changeset::NEW
    type "DeletionChangeset"
  end
end
