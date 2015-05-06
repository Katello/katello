module Katello
  class SystemActivationKey < Katello::Model
    self.include_root_in_json = false

    belongs_to :system, :inverse_of => :system_activation_keys
    belongs_to :activation_key, :inverse_of => :system_activation_keys
  end
end
