require 'test_helper'
require File.join(Rails.root, 'test/active_support_test_case_helper.rb')
require File.join(Rails.root, 'test/unit/foreman/access_permissions_test')

# Permissions are added in AccessPermissions with lists of controllers and
# actions that they enable access to.  For non-admin users, we need to test
# that there are permissions available that cover every controller action, else
# it can't be delegated and this will lead to parts of the application that
# aren't functional for non-admin users.
#
# In particular, it's important that actions for AJAX requests are added to
# an appropriate permission so views using those requests function.
module Katello
  class AccessPermissionsTest < ActiveSupport::TestCase
    include AccessPermissionsTestBase

    # Our Foreman routes have the foreman test skipped in ./lib/katello/plugin.rb

    KATELLO_SUB_MAN_AUTH = [
      'katello/api/rhsm/candlepin_proxies/upload_tracer_profile',
      'katello/api/rhsm/candlepin_proxies/consumer_destroy',
      'katello/api/rhsm/candlepin_proxies/enabled_repos',
      'katello/api/rhsm/candlepin_proxies/checkin',
      'katello/api/rhsm/candlepin_proxies/facts',
      'katello/api/rhsm/candlepin_proxies/available_releases',
      'katello/api/rhsm/candlepin_proxies/put',
      'katello/api/rhsm/candlepin_proxies/post',
      'katello/api/rhsm/candlepin_proxies/get',
      'katello/api/rhsm/candlepin_proxies/delete',
      'katello/api/rhsm/candlepin_proxies/serials'
    ].freeze

    KATELLO_NON_AUTH = [
      'katello/api/v2/repositories/gpg_key_content',
      'katello/api/rhsm/candlepin_proxies/server_status',
      'katello/api/rhsm/candlepin_proxies/consumer_activate',
      'katello/api/v2/ping/index',
      'katello/api/v2/ping/server_status',
      'katello/api/v2/katello_ping/index',
      'katello/api/v2/katello_ping/server_status',
      'katello/api/v2/root/rhsm_resource_list',
      'katello/react/index'
    ].freeze

    check_routes(Katello::Engine.routes, KATELLO_SUB_MAN_AUTH + KATELLO_NON_AUTH)
  end
end
