module Katello
  class ReactController < ::ApplicationController
    skip_before_action :authorize

    include Rails.application.routes.url_helpers

    def index
      render 'katello/layouts/react', :layout => false
    end
  end
end
