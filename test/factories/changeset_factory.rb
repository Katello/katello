FactoryGirl.define do
  factory :katello_changeset, :class => Katello::Changeset do
    name "changeset"
    state Katello::Changeset::NEW
  end

  factory :katello_promotion_changeset, :class => Katello::PromotionChangeset do
    name "promotion changeset"
    state Katello::Changeset::NEW
    type "Katello::PromotionChangeset"
  end

  factory :katello_deletion_changeset, :class => Katello::DeletionChangeset do
    sequence(:name) {|n| "deletion_changeset#{n}"}
    state Katello::Changeset::NEW
    type "Katello::DeletionChangeset"
  end
end
