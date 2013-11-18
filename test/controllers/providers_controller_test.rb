# encoding: utf-8
#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require "katello_test_helper"

module Katello
class ProvidersControllerTest < ActionController::TestCase

  def setup
    setup_controller_defaults
    @org = katello_organizations(:acme_corporation)
    @redhat_product = katello_providers(:redhat)
    @custom_product = katello_providers(:fedora_hosted)
    login_user(User.find(users(:admin)))
    set_organization(@org)

    models = ["Organization", "KTEnvironment", "Provider", "Product"]
    services = ["Candlepin", "Pulp", "ElasticSearch", "Foreman"]
    disable_glue_layers(services, models)
    Provider.stubs(:display_attributes).returns([])
  end

  test 'test index should be successful' do
    get :index
    assert_response :success
  end

end
end
