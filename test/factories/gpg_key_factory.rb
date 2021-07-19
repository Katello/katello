FactoryBot.define do
  factory :katello_gpg_key, :class => Katello::ContentCredential do
    sequence(:content) { |n| "abc123#{n}" }
  end
end
