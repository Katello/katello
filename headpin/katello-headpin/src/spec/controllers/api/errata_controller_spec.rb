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

require 'spec_helper.rb'

describe Api::ErrataController, :katello => true do
  include LoginHelperMethods
  include AuthorizationHelperMethods

  before(:each) do
    login_user_api
  end

  describe "get a listing of erratas" do

    before(:each) do
      @repo = mock(Glue::Pulp::Repo)
      Glue::Pulp::Errata.stub(:filter => [])
    end

    it "should call pulp find repo api" do
      Glue::Pulp::Errata.should_receive(:filter).once.with(:repoid => 1).and_return([])

      get 'index', :repoid => 1
    end

    it "should accept type as filter attribute" do
      Glue::Pulp::Errata.should_receive(:filter).once.with(:repoid => 1, :type => 'security').and_return([])
      get 'index', :repoid => 1, :type => 'security'

      Glue::Pulp::Errata.should_receive(:filter).once.with(:type => 'security', :environment_id => '123').and_return([])
      get 'index', :type => 'security', :environment_id => "123"

      Glue::Pulp::Errata.should_receive(:filter).once.with(:severity => 'critical', :environment_id => '123').and_return([])
      get 'index', :severity => 'critical', :environment_id => "123"

      Glue::Pulp::Errata.should_receive(:filter).once.with(:severity => 'critical', :product_id => 'product-123', :environment_id => '123').and_return([])
      get 'index', :severity => 'critical', :product_id => 'product-123', :environment_id => "123"
    end

    it "should not accept a call without specifying envirovnemnt or repoid" do
      get 'index', :type => 'security'
      response.response_code.should == 400
    end
  end

  describe "show an erratum" do
    it "should call pulp find errata api" do
      Glue::Pulp::Errata.should_receive(:find).once.with(1)
      get 'show', :id => 1
    end
  end

end

