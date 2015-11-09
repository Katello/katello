require 'katello_test_helper'

module Katello
  class RepositoryTestBase < ActiveSupport::TestCase
    def setup
      @acme_corporation              = get_organization

      @fedora_17_x86_64              = katello_repositories(:fedora_17_x86_64)
      @fedora_17_x86_64_dev          = katello_repositories(:fedora_17_x86_64_dev)
      @fedora_17_library_library_view = katello_repositories(:fedora_17_library_library_view)
      @fedora_17_dev_library_view     = katello_repositories(:fedora_17_dev_library_view)
      @puppet_forge                  = katello_repositories(:p_forge)
      @redis                         = katello_repositories(:redis)
      @fedora                        = katello_products(:fedora)
      @library                       = katello_environments(:library)
      @dev                           = katello_environments(:dev)
      @staging                       = katello_environments(:staging)
      @unassigned_gpg_key            = katello_gpg_keys(:unassigned_gpg_key)
      @library_dev_staging_view      = katello_content_views(:library_dev_staging_view)
      @library_view                  = katello_content_views(:library_view)
      @admin                         = users(:admin)
    end
  end
end
