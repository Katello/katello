module Katello
  module Actions

    require 'katello/actions/changeset_promote'
    require "katello/actions/content_view_create"
    require 'katello/actions/content_view_demote'
    require 'katello/actions/content_view_promote'
    require 'katello/actions/node_metadata_generate'

    require 'katello/actions/environment_create'
    require 'katello/actions/environment_destroy'

    require 'katello/actions/repository_create'
    require 'katello/actions/repository_destroy'
    require 'katello/actions/repository_sync'

  end
end
