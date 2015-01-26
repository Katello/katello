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
require 'helpers/product_test_data'

# used for including tested module
module Katello
  class DummyObject
    include SyncManagementHelper
    include SyncManagementHelper::RepoMethods
  end
end

module Katello
  describe SyncManagementHelper do
    include OrchestrationHelper

    before do
      @routes = Katello::Engine.routes
      disable_product_orchestration
      disable_org_orchestration
      Katello.stubs(:pulp_server).returns(stub(:extensions => stub(:repository => stub(:search_by_repository_ids => []))))
      ProductTestData::PRODUCT_WITH_ATTRS.merge!(:provider => provider, :organization => provider.organization)
    end

    let(:organization) do
      get_organization
    end
    let(:provider) { organization.redhat_provider }
    let(:env_name) { 'test_environment' }
    let(:environment) { organization.library }
    let(:object) { DummyObject.new }
    let(:product_1) { Product.create!(ProductTestData::PRODUCT_WITH_ATTRS) }

    describe "#collect_repos (katello)" do #TODO: headpin
      subject { object.collect_repos([product_1], environment).first }
      it { subject.keys.must_include(:name, :id) }
    end

    describe "#repos? (katello)" do #TODO: headpin
      subject { object.repos?(object.collect_repos([product_1], environment).first) }
      it "should return false for a product without repos" do
        subject.must_equal(false)
      end
    end

    describe "#collect_minor" do
      let(:repositories) { ['1', '2', '2', nil].map { |minor| Repository.new(:minor => minor) } }
      let(:collected_by_minor) { object.collect_minor(repositories) }
      subject { collected_by_minor }
      it { subject.size.must_equal(2) }
    end

    describe "repositories with minor" do
      let(:repositories) { ['1', '2', '2', nil].map { |minor| Repository.new(:minor => minor) } }
      subject { object.collect_minor(repositories).first }
      it { subject.size.must_equal(2) }
      it { subject.keys.must_include('1', '2') }
      it "should group repositories by minor" do
        subject['2'].size.must_equal(2)
      end
    end

    describe "repositories without minor" do
      let(:repositories) { ['1', '2', '2', nil].map { |minor| Repository.new(:minor => minor) } }
      subject { object.collect_minor(repositories).last }
      it { subject.size.must_equal(1) }
    end

    describe "#collect_arches" do
      let(:repositories) { %w(i386 i386 x86_64).map { |arch| Repository.new(:arch => arch) } }
      subject { object.collect_arches(repositories) }
      it { subject.size.must_equal(2) }
      it { subject.keys.must_include('i386', 'x86_64') }
      it "should group repositories by architecture" do
        subject['i386'].size.must_equal(2)
      end
    end

    describe "#minors" do
      subject { object.minors('1' => [Repository.new]).first }
      it { subject.keys.must_include(:id, :name) }
    end

    describe "#arches" do
      subject { object.arches([Repository.new(:arch => 'i386')]).first }
      it { subject.keys.must_include(:id, :name) }
    end
  end
end
