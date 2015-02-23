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
  class Api::V2::SystemErrataControllerTest < ActionController::TestCase
    include Support::ForemanTasks::Task

    def self.before_suite
      models = ["System"]
      disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
      super
    end

    def permissions
      @view_permission = :view_content_hosts
      @create_permission = :create_content_hosts
      @update_permission = :edit_content_hosts
      @destroy_permission = :destroy_content_hosts
    end

    def setup
      setup_controller_defaults_api
      login_user(User.find(users(:admin)))
      @request.env['HTTP_ACCEPT'] = 'application/json'

      @system = katello_systems(:simple_server)
      permissions
    end

    def test_apply
      assert_async_task ::Actions::Katello::System::Erratum::Install do |system, errata|
        system.id == @system.id && errata == %w(RHSA-1999-1231)
      end

      put :apply, :system_id => @system.uuid, :errata_ids => %w(RHSA-1999-1231)

      assert_response :success
    end

    def test_apply_unknown_errata
      put :apply, :system_id => @system.uuid, :errata_ids => %w(non-existant-errata)
      assert_response 404
    end

    def test_apply_protected
      good_perms = [@update_permission]
      bad_perms = [@view_permission, @create_permission, @destroy_permission]

      assert_protected_action(:apply, good_perms, bad_perms) do
        put :apply, :system_id => @system.uuid, :errata_ids => %w(RHSA-1999-1231)
      end
    end
  end
end
