module Katello
  class Api::V2::PuppetModulesController < Api::V2::ApiController
    apipie_concern_subst(:a_resource => N_("a puppet module"), :resource => "puppet_modules")
    include Katello::Concerns::Api::V2::RepositoryContentController
  end
end
