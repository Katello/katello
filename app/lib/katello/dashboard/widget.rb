module Katello
  class Dashboard::Widget
    include Rails.application.routes.url_helpers
    include Katello::Engine.routes.url_helpers

    def initialize(organization)
      @organization = organization
    end

    def accessible?
      true
    end

    def name
      self.class.name.demodulize.underscore[/(.*)_widget/, 1]
    end

    def title
      "Widget"
    end

    def content_path
      nil
    end

    private

    # rubocop:disable TrivialAccessors
    def current_organization
      @organization
    end
  end
end
