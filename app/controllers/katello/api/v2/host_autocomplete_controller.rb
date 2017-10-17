module Katello
  class Api::V2::HostAutocompleteController < ::Api::V2::BaseController
    include ::Foreman::Controller::AutoCompleteSearch

    before_action :find_optional_nested_object

    resource_description do
      api_version 'v2'
      api_base_url "/api"
    end

    def resource_name(_resource = nil)
      'host'
    end

    def model_of_controller
      ::Host::Managed
    end

    def action_permission
      'view'
    end
  end
end
