require 'spec_helper'
include OrchestrationHelper

describe Changeset do

  describe "Changeset should" do
    before(:each) do
      disable_org_orchestration
      disable_product_orchestration

      User.current = User.find_or_create_by_username(:username => 'admin', :password => 'admin12345')
      @organization = Organization.create!(:name => 'candyroom', :cp_key => 'test_organization')
      @environment = KPEnvironment.new({:name => 'julia', :prior=>@organization.locker})
      @organization.environments << @environment
      @organization.save!
      @environment.save!
      @changeset = Changeset.new(:environment=>@environment, :name=>"foo-changeset")
      @changeset.save!
    end

    it "changeset should not be null" do
      @environment.should_not be_nil
      @environment.working_changesets.should_not be_nil
    end

    it "changeset first user should equal current user" do
      cu = ChangesetUser.new(:changeset => @changeset, :user => User.current)
      cu.save!
      @changeset.users.first.user_id.should == User.current.id
      @changeset.users.first.changeset_id.should == @changeset.id
    end

    it "changeset find or create should work" do
      cu = ChangesetUser.find_or_create_by_user_id_and_changeset_id(User.current.id, @changeset.id)
      cu.save!
      @changeset.users.first.user_id.should == User.current.id
      @changeset.users.first.changeset_id.should == @changeset.id
    end

    it "changeset find or create should work" do
      cu = ChangesetUser.find_or_create_by_user_id_and_changeset_id(User.current.id, @changeset.id)
      cu.save!
      ChangesetUser.destroy_all(:changeset_id => @changeset.id)
      @changeset.users.should be_empty
    end

    describe "fail adding content not contained in it's environment" do

      it "should fail on add product" do
        lambda {@changeset.add_product("prod")}.should raise_error
      end

      it "should fail on add package" do
        lambda {@changeset.add_package("pack")}.should raise_error
      end

      it "should fail on add erratum" do
        lambda {@changeset.add_erratum("err")}.should raise_error
      end

      it "should fail on add repo" do
        lambda {@changeset.add_repo("repo")}.should raise_error
      end
    end

    describe "adding content from it's environment" do

      before(:each) do
        @provider = Provider.create!(:name => "provider", :provider_type => Provider::CUSTOM, :organization => @organization)

        @prod = Product.new({:name => "prod"})
        @prod.provider = @provider
        @prod.environments << @organization.locker
        @prod.environments << @environment
        @prod.stub(:arch).and_return('noarch')
        @prod.save!

        @pack = mock('Pack', {:id => 1, :name => 'pack'})
        @err  = mock('Err', {:id => 'err', :name => 'err'})

        @repo = mock('Repo', {:id => 1, :name => 'repo'})
        @repo.stub(:packages).and_return([@pack])
        @repo.stub(:errata).and_return([@err])

        @prod.stub(:repos).and_return([@repo])

        @environment.prior.stub(:products).and_return([@prod])
        @environment.prior.products.stub(:find_by_name).and_return(@prod)
      end

      it "should add product" do
        @changeset.add_product("prod")
        @changeset.products.should include @prod
      end

      it "should add package" do
        @changeset.add_package("pack")
        @changeset.packages.length.should == 1
      end

      it "should add erratum" do
        @changeset.add_erratum("err")
        @changeset.errata.length.should == 1
      end

      it "should add repo" do
        @changeset.add_repo("repo")
        @changeset.repos.length.should == 1
      end

    end

    describe "removing content" do

      before(:each) do
        @provider = Provider.create!(:name => "provider", :provider_type => Provider::CUSTOM, :organization => @organization)

        @prod = Product.new({:name => "prod"})
        @prod.provider = @provider
        @prod.environments << @organization.locker
        @prod.environments << @environment
        @prod.stub(:arch).and_return('noarch')
        @prod.save!

        @pack = mock('Pack', {:id => 1, :name => 'pack'})
        @err  = mock('Err', {:id => 'err', :name => 'err'})

        @repo = mock('Repo', {:id => 1, :name => 'repo'})
        @repo.stub(:packages).and_return([@pack])
        @repo.stub(:errata).and_return([@err])

        @prod.stub(:repos).and_return([@repo])

        @environment.prior.stub(:products).and_return([@prod])
        @environment.prior.products.stub(:find_by_name).and_return(@prod)
      end

      it "should remove product" do
        @changeset.products.should_receive(:delete).with(@prod).and_return(true)
        @changeset.remove_product("prod")
      end

      it "should remove package" do
        ChangesetPackage.should_receive(:destroy_all).with(:package_id => 1, :changeset_id => @changeset.id).and_return(true)
        @changeset.remove_package("pack")
      end

      it "should remove erratum" do
        ChangesetErratum.should_receive(:destroy_all).with(:errata_id => 'err', :changeset_id => @changeset.id).and_return(true)
        @changeset.remove_erratum("err")
      end

      it "should remove repo" do
        ChangesetRepo.should_receive(:destroy_all).with(:repo_id => 1, :changeset_id => @changeset.id).and_return(true)
        @changeset.remove_repo("repo")
      end

    end

    #TODO: test promotions

  end

end
