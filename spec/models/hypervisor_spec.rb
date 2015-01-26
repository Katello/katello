#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'katello_test_helper'
require 'helpers/system_test_data'

module Katello
  describe Hypervisor do
    include OrchestrationHelper
    include OrganizationHelperMethods

    before do
      disable_org_orchestration

      @organization = get_organization
      @environment = create_environment(:name => 'test', :label => 'test', :prior => @organization.library.id, :organization => @organization)
      @content_view = @environment.content_views.first
    end

    describe "creating" do
      let(:virt_who_params) { {"env" => @environment.name, "host2" => %w(GUEST3 GUEST4), "owner" => @organization.name} }
      let(:new_hypervisor_attrs) { SystemTestData.new_hypervisor }
      let(:hypervisor_record) { Hypervisor.find_by_uuid(new_hypervisor_attrs[:uuid]) }

      before do
        Resources::Candlepin::Consumer.expects(:register_hypervisors).with(virt_who_params).returns({"created" => [new_hypervisor_attrs]}.with_indifferent_access)
      end

      it "should call cp" do
        System.register_hypervisors(@environment, @content_view, virt_who_params)
      end

      it "should create hypervisor record" do
        System.register_hypervisors(@environment, @content_view, virt_who_params)
        hypervisor_record.wont_be_nil
      end

      it "should not create candlepin consumer" do
        Resources::Candlepin::Consumer.expects(:create).never
        System.register_hypervisors(@environment, @content_view, virt_who_params)
      end

      it "shoudl have lazy_attributes set" do
        _response, hypervisors = System.register_hypervisors(@environment, @content_view, virt_who_params)
        hypervisors.first.lazy_attributes.wont_be_nil
      end
    end

    describe "unsupported actions" do
      subject { System.create_hypervisor(@environment.id, @content_view.id, SystemTestData.new_hypervisor) }

      [:package_profile, :pulp_facts, :simple_packages, :errata, :del_pulp_consumer, :set_pulp_consumer,
       :update_pulp_consumer, :upload_package_profile, :install_package, :uninstall_package,
       :update_package, :install_package_group, :uninstall_package_group].each do |unsupported_action|
        specify do
          proc { subject.send(unsupported_action) }.must_raise(Katello::Errors::UnsupportedActionException)
        end
      end
    end
  end
end
