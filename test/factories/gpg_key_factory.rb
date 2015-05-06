FactoryGirl.define do
  factory :katello_gpg_key, :class => Katello::GpgKey do
    sequence(:content) { |n| "abc123#{n}" }
  end
end
