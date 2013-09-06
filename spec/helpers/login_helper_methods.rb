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

require 'models/model_spec_helper'
include OrchestrationHelper

module LoginHelperMethods
  def login_user options={}
    if options[:mock] == false
      if options[:user]
        @user = options[:user]
      else
        disable_user_orchestration

        @user = User.create(:username => "foo-user", :password => "password", :email => "foo-user@somewhere.com", :page_size=>25)
        @permission = Permission.create!(:role =>@user.roles.first, :all_types => true, :name => "superadmin")
      end

      request.env['warden'] = mock(Warden, :user => @user, :authenticate => @user, :authenticate! => @user,
                                   :raw_session => mock(:raw_session).as_null_object, :logout => true)
      controller.stub!(:require_org).and_return({})
      return @user
    else
      @mock_user = options[:user]
      @mock_user ||= mock_model(User, :username=>"test_mock_user", :password=>"Password", :experimental_ui => false,
                                :email=>"test_mock_user@somewhere.com", :page_size=>25).as_null_object
      request.env['warden'] = mock(Warden, :user => @mock_user, :authenticate => @mock_user, :authenticate! => @mock_user)
      controller.stub!(:require_org).and_return({})
      return @mock_user
    end
  end

  def setup_current_organization(org = nil)
    if org.nil?
      @mock_org = mock(Organization)
      @mock_org.stub!(:name).and_return("admin_one")
      @mock_org.stub!(:label).and_return("admin_one")
      @mock_org.stub!(:being_deleted?).and_return(false)
      org = @mock_org
    end

    controller.stub!(:current_organization).and_return(org)
  end

  def login_user_api user=nil
    @mock_user = user
    @mock_user ||= mock_model(User, :username=>"test_mock_user", :password=>"Password", :email=>"test_mock_user@somewhere.com", :page_size=>25).as_null_object
    request.env['warden'] = mock(Warden, :user => @mock_user, :authenticate => @mock_user, :authenticate! => @mock_user)
    controller.stub!(:require_user).and_return({})
    controller.stub!(:current_user).and_return(@mock_user)
    User.stub(:current).and_return(@mock_user)
    return @mock_user
  end

  def mock_auth(object)
    object.stub(:updatable?).and_return(true)
    object.stub(:updatable).and_return(true)
  end
end
