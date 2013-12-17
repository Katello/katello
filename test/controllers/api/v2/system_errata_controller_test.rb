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
  class Api::V2::SystemErrataControllerTest < ActionController::TestCase

    def self.before_suite
      models = ["System"]
      disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
      super
    end

    def permissions
      @read_permission = UserPermission.new(:read_systems, :organizations, nil, @system.organization)
      @update_permission = UserPermission.new(:update_systems, :organizations, nil, @system.organization)
      @no_permission = NO_PERMISSION
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin)))
      @request.env['HTTP_ACCEPT'] = 'application/json'

      @system = katello_systems(:simple_server)
      permissions
    end

    def test_apply
      System.any_instance.expects(:install_errata).with(["foo"]).returns(TaskStatus.new)
      put :apply, :system_id => @system.uuid, :errata_ids => ["foo"]

      assert_response :success
      assert_template 'api/v2/system_errata/system_task'
    end

    def test_permissions
      good_perms = [@update_permission]
      bad_perms = [@read_permission, @no_permission ]

      assert_protected_action(:apply, good_perms, bad_perms) do
        put :apply, :system_id => @system.uuid, :errata=> ["foo*"]
      end
    end

  end
end
