#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

module LoginHelperMethods
  def login_user options={}
    if options[:mock] == false
      @user = User.create( :username => "foo-user", :password => "password", :page_size=>25 )
      @user.roles.first.update_attribute(:superadmin, true)
      request.env['warden'] = mock(Warden, :user => @user, :authenticate => @user, :authenticate! => @user)
      controller.stub!(:require_org).and_return({})
      return @user
    else
      @mock_user = options[:user]
      @mock_user ||= mock_model(User, :username=>"test_mock_user", :password=>"Password", :page_size=>25).as_null_object
      request.env['warden'] = mock(Warden, :user => @mock_user, :authenticate => @mock_user, :authenticate! => @mock_user)
      controller.stub!(:require_org).and_return({})
      return @mock_user
    end
  end

  def setup_current_organization
    @mock_org = mock(Organization)
    @mock_org.stub!(:name).and_return("admin_one")
    controller.stub!(:current_organization).and_return(@mock_org)
  end

  def login_user_api user=nil
    @mock_user = user
    @mock_user ||= mock(User).as_null_object
    request.env['warden'] = mock(Warden, :user => @mock_user, :authenticate => @mock_user, :authenticate! => @mock_user)
    controller.stub!(:require_user).and_return({})
    controller.stub!(:current_user).and_return(@mock_user)
  end
end
