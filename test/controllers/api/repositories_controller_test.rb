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

class Api::V1::RepositoriesControllerTest < MiniTest::Rails::ActionController::TestCase
  fixtures :all

  def before_suite
    models = ["Organization", "KTEnvironment", "Repository", "Product", "Provider"]
    services = ["Candlepin", "Pulp", "ElasticSearch"]
    disable_glue_layers(services, models)
  end

  def setup
    @repo = Repository.find(repositories(:fedora_17_x86_64))
    @org = organizations(:acme_corporation)
    @environment = environments(:library)
    login_user(User.find(users(:admin)))
  end

  test "importing into a repo should be successful" do
    Katello.pulp_server.resources.content.expects(:import_upload)
    post :import_into_repo, :repo_id => @repo.id, :unit_type_id => "rpm" , :id => "1", :unit_key => "foo", :unit_metadata  => "bar"
    assert_response :success
  end

end
