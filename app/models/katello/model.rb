module Katello
  class Model < ActiveRecord::Base
    include ActiveModel::ForbiddenAttributesProtection
    self.abstract_class = true

    def destroy!
      unless destroy
        fail self.errors.full_messages.join('; ')
      end
    end
  end
end
