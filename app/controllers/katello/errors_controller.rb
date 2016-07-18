module Katello
  class ErrorsController < Katello::ApplicationController
    skip_before_action :require_user, :require_org
    skip_before_action :authorize # ok - is used by warden

    # handles unknown routes from both / and /api namespaces
    def routing
      path = params['a']
      ex = HttpErrors::NotFound.new(_("Route does not exist:") + " #{path}")

      if path.match('/api/')
        # custom message which will render in JSON
        logger.error ex.message
        respond_to do |format|
          format.json { render :json => {:displayMessage => ex.message, :errors => [ex.message]}, :status => 404 }
          format.all { render :text => "#{ex.message}", :status => 404 }
        end
      else
        render_404 ex
      end
    end
  end
end
