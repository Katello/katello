module Katello
  module Authorization::FlatpakRemote
    extend ActiveSupport::Concern

    include Authorizable

    def readable?
      authorized?(:view_flatpak_remotes)
    end

    def editable?
      authorized?(:edit_flatpak_remotes)
    end

    def deletable?
      authorized?(:destroy_flatpak_remotes)
    end

    module ClassMethods
      def readable
        authorized(:view_flatpak_remotes)
      end

      def editable
        authorized(:edit_flatpak_remotes)
      end

      def deletable
        authorized(:destroy_flatpak_remotes)
      end
    end
  end
end
