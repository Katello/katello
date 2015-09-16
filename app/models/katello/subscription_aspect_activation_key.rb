module Katello
  class SubscriptionAspectActivationKey < Katello::Model
    self.include_root_in_json = false

    belongs_to :subscription_aspect, :inverse_of => :subscription_aspect_activation_keys, :class_name => 'Katello::Host::SubscriptionAspect'
    belongs_to :activation_key, :inverse_of => :subscription_aspect_activation_keys, :class_name => 'Katello::ActivationKey'
  end
end
