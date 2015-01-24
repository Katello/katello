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

module Katello
  describe HostCollection do
    include OrganizationHelperMethods
    include SystemHelperMethods
    include OrchestrationHelper

    let(:uuid) { '1234' }

    before(:each) do
      disable_org_orchestration
      @org = get_organization
      @host_collection = HostCollection.create!(:name => "TestHostCollection1", :organization => @org)

      setup_system_creation
      Resources::Candlepin::Consumer.stubs(:create).returns(:uuid => uuid, :owner => {:key => uuid})
      Resources::Candlepin::Consumer.stubs(:update).returns(true)
      @environment = create_environment(:name => "DEV", :label => "DEV", :prior => @org.library, :organization => @org)
      @system = create_system(:name => "bar1", :environment => @environment, :cp_type => "system", :facts => {"Test" => ""})
    end

    describe "create should" do
      it "should create succesfully with an org (katello)" do
        grp = HostCollection.create!(:name => "TestHostCollection", :organization => @org)
        grp.wont_be_nil
      end

      it "should not allow creation of a 2nd host collection in the same org with the same name" do
        HostCollection.create!(:name => "TestHostCollection", :organization => @org)
        grp2 = HostCollection.create(:name => "TestHostCollection", :organization => @org)
        grp2.new_record?.must_equal(true)
        HostCollection.where(:name => "TestHostCollection").count.must_equal(1)
      end

      it "should allow host collections with the same name to be creatd in different orgs" do
        @org2 = Organization.create!(:name => 'test_org2', :label => 'test_org2')
        HostCollection.create!(:name => "TestHostCollection", :organization => @org)
        grp2 = HostCollection.create(:name => "TestHostCollection", :organization => @org2)
        grp2.new_record?.must_equal(false)
        HostCollection.where(:name => "TestHostCollection").count.must_equal(2)
      end
    end

    describe "delete should" do
      it "should delete a host collection successfully (katello)" do
        @host_collection.destroy
        HostCollection.where(:name => @host_collection.name).count.must_equal(0)
      end
    end

    describe "update should" do
      it "should allow the name to change" do
        @host_collection.name = "NotATestHostCollection"
        @host_collection.save!
        HostCollection.where(:name => "NotATestHostCollection").count.must_equal(1)
      end
    end

    describe "changing systems (katello)" do
      it "should allow systems to be added" do
        @system.expects(:update_host_collections)
        grp = HostCollection.create!(:name => "TestHostCollection", :organization => @org, :unlimited_content_hosts => true)
        grp.systems << @system
        grp.save!
        HostCollection.find(grp).consumer_ids.size.must_equal(1)
      end

      it "should call allow ids to be removed" do
        @system.expects(:update_host_collections).twice
        grp = HostCollection.create!(:name => "TestHostCollection", :organization => @org, :unlimited_content_hosts => true)
        grp.systems << @system
        grp.systems = grp.systems - [@system]
        grp.save!
        HostCollection.find(grp).consumer_ids.size.must_equal(0)
      end
    end

    describe "actions (katello)" do
      it "should raise exception on package install, if no systems in host collection" do
        lambda { @host_collection.install_packages("pkg1") }.must_raise(Errors::HostCollectionEmptyException)
      end

      it "should raise exception on package update, if no systems in host collection" do
        lambda { @host_collection.update_packages("pkg1") }.must_raise(Errors::HostCollectionEmptyException)
      end

      it "should raise exception on package remove, if no systems in host collection" do
        lambda { @host_collection.uninstall_packages("pkg1") }.must_raise(Errors::HostCollectionEmptyException)
      end

      it "should raise exception on package group install, if no systems in host collection" do
        lambda { @host_collection.install_package_groups("grp1") }.must_raise(Errors::HostCollectionEmptyException)
      end

      it "should raise exception on package group remove, if no systems in host collection" do
        lambda { @host_collection.uninstall_package_groups("grp1") }.must_raise(Errors::HostCollectionEmptyException)
      end

      it "should raise exception on errata install, if no systems in host collection" do
        lambda { @host_collection.install_errata("errata1") }.must_raise(Errors::HostCollectionEmptyException)
      end
    end
  end
end
