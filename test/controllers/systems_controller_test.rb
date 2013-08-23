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

require "test_helper"

describe SystemsController do
  fixtures :all

  before do
    models = ["Organization", "KTEnvironment", "User", "Filter",
                "FilterRule", "ErratumRule", "PackageRule", "PackageGroupRule",
                "ContentViewEnvironment", "ContentViewDefinition", "System"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
    @system = systems(:simple_server)
    @org = @system.organization
    login_user(User.find(users(:admin)), @org)
  end

  describe "update"  do
    before do
      @content_view = content_views(:library_dev_view)
      @cv_id = @content_view.id
      @env_id = @system.environment.id
      @subscribe_permission = UserPermission.new(:subscribe, :content_views, @cv_id, @content_view.organization)
      @edit_system_perm = UserPermission.new(:update_systems, :environments,
                          @env_id, @system.environment.organization)

      @req = lambda do
        put :update, :id => @system.id, :system => {:content_view_id => @cv_id}
      end
    end

    it "permission" do
      master_perm = @subscribe_permission + @edit_system_perm
      action = :update
      assert_authorized(
                :permission => master_perm,
                :action => action,
                :request => @req
      )
      refute_authorized(
          :permission => [@edit_system_perm, @subscribe_permission, NO_PERMISSION],
          :action => action,
          :request => @req
      )
    end
  end
end
