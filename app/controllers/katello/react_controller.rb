module Katello
  class ReactController < ::ApplicationController
    def index
      render 'katello/layouts/react', :layout => false
    end
  end
end
