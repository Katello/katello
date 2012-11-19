FactoryGirl.define do
  factory :changeset do
    name "changeset"
    state Changeset::NEW
  end

  factory :promotion_changeset do
    name "promotion changeset"
    state Changeset::NEW
  end
end
