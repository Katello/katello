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

require "minitest_helper"

class ProvidersControllerTest < MiniTest::Rails::ActionController::TestCase
  fixtures :all

  def setup
    @org = organizations(:acme_corporation)
    @redhat_product = providers(:redhat)
    @custom_product = providers(:fedora_hosted)
    login_user(User.find(users(:admin)), @org)


    models = ["Organization", "KTEnvironment"]
    services = ["Candlepin", "Pulp", "ElasticSearch", "Foreman"]
    disable_glue_layers(services, models)
  end

  test 'test index should be successful' do
    get :index
    assert_response :success
  end


end
