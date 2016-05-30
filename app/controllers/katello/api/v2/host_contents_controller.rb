module Katello
  class Api::V2::HostContentsController < Katello::Api::V2::ApiController
    def_param_group :content_facet_attributes do
      param :content_view_id, Integer
      param :lifecycle_environment_id, Integer
      param :kickstart_repository_id, Integer, :desc => N_("Repository Id associated with the kickstart repo used for provisioning")
    end
  end
end
