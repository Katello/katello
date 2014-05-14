# encoding: utf-8
#
# Copyright 2014 Red Hat, Inc.
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
  describe Api::V1::CandlepinProxiesController do

    before do
      models = ["Organization", "KTEnvironment", "User", "ContentViewFilter",
                "ContentViewEnvironment", "System", "HostCollection", "ActivationKey"]
      disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
      setup_controller_defaults_api
      login_user(User.find(users(:admin)))
      @system = katello_systems(:simple_server)
      @organization = get_organization
    end

    describe "register with activation key"  do
      it "should fail without specifying owner (organization)" do
        post('consumer_activate', :activation_keys => 'non_existent_key')
        assert_response 404
      end

      it "should fail with unknown organization" do
        post('consumer_activate', :owner => 'not_an_organization', :activation_keys => 'non_existent_key')
        assert_response 404
      end

      it "should fail with known organization and no activation_keys" do
        post('consumer_activate', :owner => @organization.name, :activation_keys => '')
        assert_response 400
      end
    end
  end
end
