require 'katello_test_helper'

module Katello
  class UserTestBase < ActiveSupport::TestCase
    extend ActiveRecord::TestFixtures

    def setup
      @no_perms_user      = User.find(users(:one))
      @admin              = User.find(users(:admin))
      @acme_corporation   = get_organization

      @dev                = KTEnvironment.find(katello_environments(:dev).id)
    end
  end
end
