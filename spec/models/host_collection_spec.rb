require 'katello_test_helper'

module Katello
  describe HostCollection do
    include Support::Actions::Fixtures
    include OrganizationHelperMethods
    include OrchestrationHelper

    let(:uuid) { '1234' }

    before(:each) do
      disable_org_orchestration
      @org = get_organization
      @host_collection = HostCollection.create!(:name => "TestHostCollection1", :organization => @org)

      Resources::Candlepin::Consumer.stubs(:create).returns(:uuid => uuid, :owner => {:key => uuid})
      Resources::Candlepin::Consumer.stubs(:update).returns(true)
      @environment = create_environment(:name => "DEV", :label => "DEV", :prior => @org.library, :organization => @org)
      @host = hosts(:one)
    end

    describe "create should" do
      it "should create succesfully with an org (katello)" do
        grp = HostCollection.create!(:name => "TestHostCollection", :organization => @org)
        value(grp).wont_be_nil
      end

      it "should not allow creation of a 2nd host collection in the same org with the same name" do
        HostCollection.create!(:name => "TestHostCollection", :organization => @org)
        grp2 = HostCollection.create(:name => "TestHostCollection", :organization => @org)
        value(grp2.new_record?).must_equal(true)
        value(HostCollection.where(:name => "TestHostCollection").count).must_equal(1)
      end

      it "should allow host collections with the same name to be creatd in different orgs" do
        @org2 = Organization.create!(:name => 'test_org2', :label => 'test_org2')
        HostCollection.create!(:name => "TestHostCollection", :organization => @org)
        grp2 = HostCollection.create(:name => "TestHostCollection", :organization => @org2)
        value(grp2.new_record?).must_equal(false)
        value(HostCollection.where(:name => "TestHostCollection").count).must_equal(2)
      end

      it "should not allow unlimited_hosts=false and max_hosts to be nil at the same time" do
        create = lambda do
          HostCollection.create!(:name => "TestHostCollection", :organization => @org, :unlimited_hosts => false)
        end
        value { create }.must_raise(ActiveRecord::RecordInvalid)
      end
    end

    describe "delete should" do
      it "should delete a host collection successfully (katello)" do
        @host_collection.destroy
        value(HostCollection.where(:name => @host_collection.name).count).must_equal(0)
      end
    end

    describe "update should" do
      it "should allow the name to change" do
        @host_collection.name = "NotATestHostCollection"
        @host_collection.save!
        value(HostCollection.where(:name => "NotATestHostCollection").count).must_equal(1)
      end
    end

    describe "changing hosts" do
      it "should allow hosts to be added" do
        grp = HostCollection.create!(:name => "TestHostCollection", :organization => @org, :unlimited_hosts => true)
        grp.hosts << @host
        grp.save!
        value(HostCollection.find(grp.id).host_ids.size).must_equal(1)
        value(HostCollection.find(grp.id).hosts).must_include(@host)
      end

      it "should call allow ids to be removed" do
        grp = HostCollection.create!(:name => "TestHostCollection", :organization => @org, :unlimited_hosts => true)
        grp.hosts << @host
        grp.hosts = grp.hosts - [@host]
        grp.save!
        value(HostCollection.find(grp.id).host_ids.size).must_equal(0)
      end
    end

    describe "errata" do
      before(:each) do
        @host_collection.hosts << @host
      end

      it "should retrieve errata for the hosts in the host collection" do
        errata = @host_collection.errata
        value(errata.length).must_equal(2)
      end

      it "should retrieve a specific type of errata for the hosts in the host collection" do
        errata = @host_collection.errata("security")
        value(errata.length).must_equal(1)
        value(errata).must_include(katello_errata("security"))
      end
    end
  end
end
