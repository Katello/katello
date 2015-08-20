module Katello
  module Authorization::GpgKey
    extend ActiveSupport::Concern

    include Authorizable

    def readable?
      authorized?(:view_gpg_keys)
    end

    def editable?
      authorized?(:edit_gpg_keys)
    end

    def deletable?
      authorized?(:destroy_gpg_keys)
    end

    module ClassMethods
      def readable
        authorized(:view_gpg_keys)
      end
    end
  end
end
