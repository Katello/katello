module Katello
  class PoolActivationKey < Katello::Model
    belongs_to :pool, :inverse_of => :pool_activation_keys, :class_name => 'Katello::Pool'
    belongs_to :activation_key, :inverse_of => :pool_activation_keys, :class_name => 'Katello::ActivationKey'
  end
end
