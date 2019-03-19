module Bastion
  class BastionController < ::ApplicationController
    helper 'bastion/layout'
    skip_before_action :authorize

    # prevent Foreman routes from being incorrectly generated (don't use the Bastion url_helpers)
    include Rails.application.routes.url_helpers

    def index
      render 'bastion/layouts/application', :layout => false
    end

    def index_ie
      render 'bastion/layouts/application_ie', :layout => false
    end
  end
end
