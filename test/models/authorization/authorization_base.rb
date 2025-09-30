require 'katello_test_helper'

module Katello
  class AuthorizationTestBase < ActiveSupport::TestCase
    include Katello::AuthorizationSupportMethods

    def setup
      @acme_corporation   = get_organization
      @no_perms_user      = User.find(users(:restricted).id)
      @no_perms_user.organizations << @acme_corporation
      @admin = User.find(users(:admin).id)

      @fedora_hosted        = Provider.find(katello_providers(:fedora_hosted).id)
      @fedora_17_x86_64     = Repository.find(katello_repositories(:fedora_17_x86_64).id)
      @fedora_17_x86_64_dev = Repository.find(katello_repositories(:fedora_17_x86_64_dev).id)
      @fedora               = Product.find(katello_products(:fedora).id)
      @library              = KTEnvironment.find(katello_environments(:library).id)
      @dev                  = KTEnvironment.find(katello_environments(:dev).id)
      @unassigned_gpg_key   = ContentCredential.find(katello_gpg_keys(:unassigned_gpg_key).id)
    end
  end
end
