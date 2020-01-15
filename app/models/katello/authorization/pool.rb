module Katello
  module Authorization::Pool
    extend ActiveSupport::Concern

    def readable?
      self.class.readable.where(id: self.id).any?
    end

    module ClassMethods
      def readable
        where(:subscription_id => Katello::Subscription.readable)
      end
    end
  end
end
