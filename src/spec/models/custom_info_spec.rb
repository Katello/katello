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

require 'spec_helper'
include OrchestrationHelper
include SystemHelperMethods

describe CustomInfo do

  include AuthorizationHelperMethods

  let(:uuid) { '1234' }

  before(:each) do
    disable_org_orchestration

    @organization = Organization.create!(:name => "test_org", :label => "test_org")
    @environment = KTEnvironment.create!(:name => "test_env", :label => "test_env", :prior => @organization.library.id, :organization => @organization)

    Resources::Candlepin::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
    Resources::Candlepin::Consumer.stub!(:update).and_return(true)

    Runcible::Extensions::Consumer.stub!(:create).and_return({:id => uuid})

    @system = System.create!(:name => "test_system", :environment => @environment, :cp_type => 'system', :facts => {"distribution.name" => "Fedora"})

    CustomInfo.skip_callback(:save, :after, :reindex_informable)
    CustomInfo.skip_callback(:destroy, :after, :reindex_informable)
  end

  context "CustomInfo in invalid state should not be valid", :katello => true do #TODO headpin
    specify { CustomInfo.new.should_not be_valid }
    specify { CustomInfo.new(:keyname => "test").should_not be_valid }
    specify { CustomInfo.new(:value => "1234").should_not be_valid }
    specify { CustomInfo.new(:keyname => "test", :value => "1234").should_not be_valid }
  end

  context "CustomInfo in valid state should be valid", :katello => true do #TODO headpin
    specify { @system.custom_info.new(:keyname => "test", :value => "1234").should be_valid }
    specify { @system.custom_info.new(:keyname => "test", :value => "abcd").should be_valid }
    specify { @system.custom_info.new(:keyname => "test").should be_valid }
  end

  it "should not allow duplicate keynames", :katello => true do #TODO headpin
    @system.custom_info.create!(:keyname => "test", :value => "1234")
    @system.custom_info.new(:keyname => "test", :value => "asdf").should_not be_valid
  end
end
