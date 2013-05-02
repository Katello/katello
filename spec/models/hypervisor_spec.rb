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
require 'helpers/system_test_data'

include OrchestrationHelper

describe Hypervisor do
  before do
    disable_org_orchestration

    @organization = Organization.create!(:name=>'test_org', :label=> 'test_org')
    @environment = KTEnvironment.create!(:name=>'test', :label=> 'test', :prior => @organization.library.id, :organization => @organization)

  end

  describe "creating" do
    let(:virt_who_params) { {"env"=>@environment.name, "host2"=>["GUEST3", "GUEST4"], "owner"=>@organization.name} }
    let(:new_hypervisor_attrs) { SystemTestData.new_hypervisor }
    let(:hypervisor_record) { Hypervisor.find_by_uuid(new_hypervisor_attrs[:uuid]) }

    before do
      Resources::Candlepin::Consumer.stub(:register_hypervisors).with(virt_who_params).and_return({"created" => [new_hypervisor_attrs]}.with_indifferent_access)
    end

    it "should call cp" do
      Resources::Candlepin::Consumer.should_receive(:register_hypervisors).with(virt_who_params)
      System.register_hypervisors(@environment, virt_who_params)
    end

    it "should create hypervisor record" do
      System.register_hypervisors(@environment, virt_who_params)
      hypervisor_record.should be
    end

    it "should not create candlepin consumer" do
      Resources::Candlepin::Consumer.should_not_receive(:create)
      System.register_hypervisors(@environment, virt_who_params)
    end

    it "shoudl have lazy_attributes set" do
      response, hypervisors = System.register_hypervisors(@environment, virt_who_params)
      hypervisors.first.lazy_attributes.should_not == nil
    end
  end

  describe "unsupported actions" do
    subject { System.create_hypervisor(@environment.id, SystemTestData.new_hypervisor) }

    [:package_profile, :pulp_facts, :simple_packages, :errata, :del_pulp_consumer, :set_pulp_consumer,
     :update_pulp_consumer, :upload_package_profile, :install_package, :uninstall_package,
     :update_package, :install_package_group, :uninstall_package_group].each do |unsupported_action|
      specify do
        expect { subject.send(unsupported_action) }.to raise_error Errors::UnsupportedActionException
      end
    end
  end

end

