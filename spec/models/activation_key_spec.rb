require "katello_test_helper"

module Katello
  describe ActivationKey do
    include OrchestrationHelper

    let(:aname) { 'myactkey' }
    let(:adesc) { 'my activation key description' }

    before(:each) do
      disable_org_orchestration
      disable_activation_key_orchestration

      @organization = get_organization
      @environment_1 = katello_environments(:dev)
      @environment_2 = katello_environments(:staging)

      @library_cve = katello_content_view_environments(:library_default_view_environment)
      @dev_cve = katello_content_view_environments(:library_dev_view_dev)
      @staging_cve = katello_content_view_environments(:library_dev_staging_view_staging)

      @akey = ActivationKey.create(:name => aname, :description => adesc, :organization => @organization,
                                   :unlimited_hosts => false,
                                   :max_hosts => 1)
    end

    describe "in valid state" do
      it "should be valid if the environment is Library" do
        @akey.name = 'valid key'
        @akey.content_view_environments = [@library_cve]
        value(@akey).must_be :valid?
        value(@akey.errors[:base]).must_be_empty
      end
    end

    describe "in invalid state" do
      before { @akey = ActivationKey.new }

      it "should be invalid without name" do
        value(@akey).wont_be :valid?
        value(@akey.errors[:name]).wont_be_empty
      end

      it "should be invalid without default environment" do
        @akey.name = 'invalid key'
        value(@akey).must_be :valid?
        value(@akey.errors[:base]).must_be_empty
      end

      it "should be invalid if environment in another org is specified" do
        skip "TODO - should be in CVE"
        org_2 = get_organization(:organization2)
        #Organization.create!(:name=>'test_org2', :label=> 'test_org2')
        env_1_org2 = KTEnvironment.create(:name => 'dev', :label => 'dev', :prior => org_2.library.id, :organization => org_2)
        @akey.name = 'invalid key'
        @akey.organization = @organization
        @akey.environment = env_1_org2
        value(@akey).wont_be :valid?
        value(@akey.errors[:environment]).wont_be_empty
      end
    end

    it "should be able to create" do
      value(@akey).wont_be :nil?
    end

    describe "should be able to update" do
      it "name" do
        a = ActivationKey.find_by_name(aname)
        value(a).wont_be :nil?
        new_name = a.name + "N"
        b = ActivationKey.update(a.id, :name => new_name)
        value(b.name).must_equal new_name
      end

      it "description" do
        a = ActivationKey.find_by_name(aname)
        value(a).wont_be :nil?
        new_description = a.description + "N"
        b = ActivationKey.update(a.id, :description => new_description)
        value(b.description).must_equal new_description
      end

      it "environment" do
        a = ActivationKey.find_by_name(aname)
        value(a).wont_be :nil?
        b = ActivationKey.update(a.id, content_view_environments: [@staging_cve])
        value(b.content_view_environments.first).must_equal @staging_cve
      end
    end

    describe "adding host collections" do
      before(:each) do
        @host_collection = HostCollection.create!(:name => "TestHostCollection", :organization => @organization)
      end

      it "should add host collections" do
        @akey.host_collections << @host_collection
        @akey.save!
        value(ActivationKey.find(@akey.id).host_collections).must_include @host_collection
      end
    end
  end
end
