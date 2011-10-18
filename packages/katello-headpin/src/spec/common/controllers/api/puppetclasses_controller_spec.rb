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

describe Api::PuppetclassesController do
  include LoginHelperMethods

  before(:each) do
    login_user_api
  end

  describe "GET 'index'" do
    it "should be successful" do
      puppet_class = Foreman::Puppetclass.new
      Foreman::Puppetclass.should_receive(:new).once.and_return(puppet_class)
      puppet_class.should_receive(:list).once.and_return([])

      get 'index', :format => :json
      response.should be_success
    end
  end

end
