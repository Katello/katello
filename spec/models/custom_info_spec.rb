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
include OrchestrationHelper
include SystemHelperMethods

describe CustomInfo do

  include AuthorizationHelperMethods

  let(:uuid) { '1234' }

  before(:each) do
    disable_org_orchestration

    @organization = Organization.create!(:name => "test_org", :cp_key => "test_org")
    @environment = KTEnvironment.create!(:name => "test_env", :prior => @organization.library.id, :organization => @organization)

    Organization.stub!(:first).and_return(@organization)

    Resources::Candlepin::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
    Resources::Candlepin::Consumer.stub!(:update).and_return(true)

    Resources::Pulp::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})

    @system = System.create!(:name => "test_system", :environment => @environment, :cp_type => 'system', :facts => {"distribution.name" => "Fedora"})
  end

  context "CustomInfo in invalid state should not be valid" do
    specify { CustomInfo.new.should_not be_valid }
    specify { CustomInfo.new(:keyname => "test").should_not be_valid }
    specify { CustomInfo.new(:value => "1234").should_not be_valid }
    specify { CustomInfo.new(:keyname => "test", :value => "1234").should_not be_valid }
  end

  context "CustomInfo in valid state should be valid" do
    specify { @system.custom_info.new(:keyname => "test", :value => "1234").should be_valid }
    specify { @system.custom_info.new(:keyname => "test", :value => "abcd").should be_valid }
  end
  #pending "add some examples to (or delete) #{__FILE__}"
end
