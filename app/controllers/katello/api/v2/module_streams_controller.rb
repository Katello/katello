module Katello
  class Api::V2::ModuleStreamsController < Api::V2::ApiController
    apipie_concern_subst(:a_resource => N_("a module stream"), :resource => "module_streams")
    include Katello::Concerns::Api::V2::RepositoryContentController

    def default_sort
      %w(name asc)
    end
  end
end
