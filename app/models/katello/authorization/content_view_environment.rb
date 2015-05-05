module Katello
  module Authorization::ContentViewEnvironment
    extend ActiveSupport::Concern

    def readable?
      self.content_view.readable? && self.environment.readable?
    end
  end
end
