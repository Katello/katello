require 'katello_test_helper'

module Katello
  class AuthorizationTestBase < ActiveSupport::TestCase
    include Katello::AuthorizationSupportMethods

    def setup
      Katello.config[:warden] = 'database'
      @no_perms_user      = User.find(users(:restricted))
      @admin              = User.find(users(:admin))
      @acme_corporation   = get_organization

      @fedora_hosted        = Provider.find(katello_providers(:fedora_hosted))
      @fedora_17_x86_64     = Repository.find(katello_repositories(:fedora_17_x86_64).id)
      @fedora_17_x86_64_dev = Repository.find(katello_repositories(:fedora_17_x86_64_dev).id)
      @fedora               = Product.find(katello_products(:fedora).id)
      @library              = KTEnvironment.find(katello_environments(:library).id)
      @dev                  = KTEnvironment.find(katello_environments(:dev).id)
      @unassigned_gpg_key   = GpgKey.find(katello_gpg_keys(:unassigned_gpg_key).id)
      @system               = System.find(katello_systems(:simple_server))
    end
  end
end
