module Katello
  class ActivationKeyPurposeAddon < Katello::Model
    belongs_to :activation_key, inverse_of: :activation_key_purpose_addons, class_name: 'Katello::ActivationKey'
    belongs_to :purpose_addon, inverse_of: :activation_key_purpose_addons, class_name: 'Katello::PurposeAddon'
  end
end
