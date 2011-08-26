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

require 'spec_helper'

describe SyncManagementController do
  include LoginHelperMethods
  include LocaleHelperMethods

  before (:each) do
    login_user
    setup_current_organization
    set_default_locale

    @locker = KTEnvironment.new
    @mock_org.stub!(:locker).and_return(@locker)
    @locker.stub!(:products).and_return(OpenStruct.new(:readable => [], :syncable=>[]))
  end

  describe "GET 'index'" do
    it "should be successful" do
      get 'index'
      response.should be_success
    end
  end

end
