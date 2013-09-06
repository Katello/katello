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

# Specs in this file have access to a helper object that includes
# the SyncManagementHelper. For example:
#
# describe SyncManagementHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end

# used for including tested module
class DummyObject
  include SyncManagementHelper
  include SyncManagementHelper::RepoMethods
end

describe SyncManagementHelper do
  include OrchestrationHelper
  before do
    disable_product_orchestration
    disable_org_orchestration
    Katello.pulp_server.extensions.repository.stub(:search_by_repository_ids).and_return([]) if Katello.config.katello?
    ProductTestData::PRODUCT_WITH_ATTRS.merge!({ :provider => provider })
  end

  let(:organization) { Organization.create!(:name => 'test_organization', :label => 'test_organization') }
  let(:provider) { organization.redhat_provider }
  let(:env_name) { 'test_environment' }
  let(:environment) { organization.library }
  let(:object) { DummyObject.new }
  let(:product_1) { Product.create!(ProductTestData::PRODUCT_WITH_ATTRS) }
  describe "#collect_repos", :katello => true do #TODO headpin
    subject { object.collect_repos([product_1], environment).first }
    its(:keys) { should include(:name, :id, :type, :repos, :children, :organization) }
  end

  describe "#collect_minor" do
    let(:repositories) { ['1', '2', '2', nil].map { |minor| Repository.new(:minor => minor) } }
    let(:collected_by_minor) { object.collect_minor(repositories) }
    subject { collected_by_minor }
    its(:size) { should eql(2) }

    describe "repositories with minor" do
      subject { collected_by_minor.first }
      its(:size) { should eql(2) }
      its(:keys) { should include('1', '2') }
      it "should group repositories by minor" do
        subject['2'].size.should eql(2)
      end
    end

    describe "repositories without minor" do
      subject { collected_by_minor.last }
      its(:size) { should eql(1) }
    end
  end

  describe "#collect_arches" do
    let(:repositories) { ['i386', 'i386', 'x86_64'].map { |arch| Repository.new(:arch => arch) } }
    subject { object.collect_arches(repositories) }
    its(:size) { should eql(2) }
    its(:keys) { should include('i386', 'x86_64') }
    it "should group repositories by architecture" do
      subject['i386'].size.should eql(2)
    end
  end

  describe "#minors" do
    subject { object.minors('1' => [Repository.new]).first }
    its(:keys) { should include(:id, :name, :type, :children, :repos)}
  end

  describe "#arches" do
    subject { object.arches([Repository.new(:arch => 'i386')]).first }
    its(:keys) { should include(:id, :name, :type, :children, :repos)}
  end
end
