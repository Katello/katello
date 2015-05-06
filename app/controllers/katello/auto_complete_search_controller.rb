module Katello
  class AutoCompleteSearchController < Katello::ApplicationController
    include Foreman::Controller::AutoCompleteSearch

    def model_of_controller
      Organization.current ? model.where(:organization_id => Organization.current.id) : model
    end

    def model
      Katello::Util::Model.controller_path_to_model("katello/#{params[:kt_path]}")
    end

    def permission_controller
      "katello/#{params[:kt_path]}"
    end
  end
end
