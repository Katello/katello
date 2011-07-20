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

describe ActivationKey do

  let(:aname) { 'myactkey' }
  let(:adesc) { 'my activation key description' }

  before(:each) do
    disable_org_orchestration

    @organization = Organization.create!(:name => 'test_org', :cp_key => 'test_org')
    @akey = ActivationKey.create!(:name => aname, :description => adesc, :organization_id => @organization.id)
  end

  it "be able to create" do
    @akey.should_not be_nil
  end

  it "be able to update" do 
    a = ActivationKey.find_by_name(aname)
    a.should_not be_nil
    new_name = a.name + "N"
    b = ActivationKey.update(a.id, {:name => new_name})
    b.name.should == new_name
  end
  
  it "should map 2way subscriptions to keys" do 
    s = KTSubscription.create!(:subscription => 'abc123')
    @akey.subscriptions = [s]
    @akey.subscriptions.first.subscription.should == 'abc123'
    s.activation_keys.first.name.should == aname
  end

end
