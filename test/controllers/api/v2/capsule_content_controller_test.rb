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
  class Api::V2::CapsuleContentControllerTest < ActionController::TestCase
    include Support::CapsuleSupport
    include Support::ForemanTasks::Task

    def setup
      Katello::Package.stubs(:package_count).returns(0)
      Katello::PuppetModule.stubs(:module_count).returns(0)
      setup_controller_defaults_api
    end

    def allowed_perms
      [:manage_capsule_content]
    end

    def denied_perms
      []
    end

    def environment
      @environment ||= katello_environments(:library)
    end

    def test_lifecycle_environments
      get :lifecycle_environments, :id => proxy_with_pulp.id
      assert_response :success
    end

    def test_lifecycle_environments_protected
      assert_protected_action(:lifecycle_environments, allowed_perms, denied_perms) do
        get :lifecycle_environments, :id => proxy_with_pulp.id
      end
    end

    def test_available_lifecycle_environments
      get :available_lifecycle_environments, :id => proxy_with_pulp.id
      assert_response :success
    end

    def test_available_lifecycle_environments_protected
      assert_protected_action(:available_lifecycle_environments, allowed_perms, denied_perms) do
        get :available_lifecycle_environments, :id => proxy_with_pulp.id
      end
    end

    def test_add_lifecycle_environment
      post :add_lifecycle_environment, :id => proxy_with_pulp.id, :environment_id => environment.id
      assert_response :success
    end

    def test_add_lifecycle_environment_protected
      assert_protected_action(:add_lifecycle_environment, [[:manage_capsule_content, :view_lifecycle_environments]], denied_perms) do
        post :add_lifecycle_environment, :id => proxy_with_pulp.id, :environment_id => environment.id
      end
    end

    def test_remove_lifecycle_environment
      capsule_content.add_lifecycle_environment(environment)

      delete :remove_lifecycle_environment, :id => proxy_with_pulp.id, :environment_id => environment.id
      assert_response :success
    end

    def test_remove_lifecycle_environment_protected
      assert_protected_action(:remove_lifecycle_environment, [[:manage_capsule_content, :view_lifecycle_environments]], denied_perms) do
        delete :remove_lifecycle_environment, :id => proxy_with_pulp.id, :environment_id => environment.id
      end
    end

    def test_sync
      assert_async_task ::Actions::Katello::CapsuleContent::Sync do |capsule_content, caps_environment|
        capsule_content.capsule.id.must_equal proxy_with_pulp.id
        caps_environment.id.must_equal environment.id
      end

      post :sync, :id => proxy_with_pulp.id, :environment_id => environment.id
      assert_response :success
    end

    def test_sync_protected
      assert_protected_action(:sync, allowed_perms, denied_perms) do
        post :sync, :id => proxy_with_pulp.id, :environment_id => environment.id
      end
    end
  end
end
