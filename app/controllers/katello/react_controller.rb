module Katello
  class ReactController < ::ApplicationController
    skip_before_action :authorize

    def index
      render 'katello/layouts/react', :layout => false
    end
  end
end
