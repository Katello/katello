module Katello
  class AngularController < ::ApplicationController
    skip_before_action :authorize

    include Rails.application.routes.url_helpers

    def index
      render 'katello/layouts/angular', :layout => false
    end
  end
end
