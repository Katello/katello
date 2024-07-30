module Katello
  module Authorization::ContentViewEnvironment
    extend ActiveSupport::Concern

    def readable?
      self.content_view.readable? && self.environment.readable?
    end

    module ClassMethods
      def readable
        where(:content_view_id => ::Katello::ContentView.readable,
              :environment_id => ::Katello::KTEnvironment.readable)
      end
    end
  end
end
