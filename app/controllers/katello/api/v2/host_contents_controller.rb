module Katello
  class Api::V2::HostContentsController < Katello::Api::V2::ApiController
    def_param_group :content_facet_attributes do
      param :content_view_environments, Array, :desc => N_("Comma-separated list of content view environment labels to be associated with the host,"\
                                              " in the format of 'lifecycle_environment_label/content_view_label'."\
                                              " Ignored if content_view_environment_ids is specified."\
                                              " Requires allow_multiple_content_views setting to be on.")
      param :content_view_environment_ids, Array, :desc => N_("Array of content view environment ids to be associated with the host. Requires allow_multiple_content_views setting to be on.")
      param :content_source_id, Integer, :desc => N_("Id of the smart proxy from which the host consumes content.")
      param :kickstart_repository_id, Integer, :desc => N_("Repository Id associated with the kickstart repo used for provisioning")
    end
  end
end
