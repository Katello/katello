require 'katello_test_helper'

module Katello
  class RepositoryTestBase < ActiveSupport::TestCase
    def setup
      @acme_corporation     = get_organization

      @fedora_17_x86_64     = Repository.find(katello_repositories(:fedora_17_x86_64).id)
      @fedora_17_x86_64_dev = Repository.find(katello_repositories(:fedora_17_x86_64_dev).id)
      @fedora               = Product.find(katello_products(:fedora).id)
      @library              = KTEnvironment.find(katello_environments(:library).id)
      @dev                  = KTEnvironment.find(katello_environments(:dev).id)
      @staging              = KTEnvironment.find(katello_environments(:staging).id)
      @unassigned_gpg_key   = GpgKey.find(katello_gpg_keys(:unassigned_gpg_key).id)
      @admin                = User.find(users(:admin))
    end
  end
end
