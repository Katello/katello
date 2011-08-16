class SystemActivationKey < ActiveRecord::Base
  belongs_to :system
  belongs_to :activation_key
end
