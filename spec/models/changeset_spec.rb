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

    describe "fail adding content not contained in the prior environment" do

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


    describe "adding content" do
      before(:each) do
        @provider = Provider.create!(:name => "provider", :provider_type => Provider::CUSTOM, :organization => @organization, :repository_url => "https://something.url/stuff")

        @prod = Product.new({:name => "prod"})
        @prod.provider = @provider
        @prod.environments << @organization.locker
        @prod.stub(:arch).and_return('noarch')
        @prod.save!

        @pack = mock('Pack', {:id => 1, :name => 'pack'})
        @err  = mock('Err', {:id => 'err', :name => 'err'})

        @repo = mock('Repo', {:id => 1, :name => 'repo'})
        @repo.stub(:packages).and_return([@pack])
        @repo.stub(:errata).and_return([@err])
        @repo.stub(:has_package?).with(1).and_return(true)
        @repo.stub(:has_erratum?).with('err').and_return(true)

        @prod.stub(:repos).and_return([@repo])
        Product.stub(:find).and_return(@prod)

        @environment.prior.stub(:products).and_return([@prod])
        @environment.prior.products.stub(:find_by_name).and_return(@prod)
      end

      describe "fail adding content from not promoted product" do

        before(:each) do
          @repo.stub(:is_cloned_in?).and_return(true)
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

      describe "fail adding content from not promoted repository" do

        before(:each) do
          @prod.environments << @environment
          @repo.stub(:is_cloned_in?).and_return(true)
        end

        it "should fail on add package" do
          lambda {@changeset.add_package("pack")}.should raise_error
        end

        it "should fail on add erratum" do
          lambda {@changeset.add_erratum("err")}.should raise_error
        end

      end

      describe "adding content from the prior environment" do

        before(:each) do
          @prod.environments << @environment
          @repo.stub(:is_cloned_in?).and_return(true)
        end

        it "should add product" do
          @changeset.add_product("prod")
          @changeset.products.should include @prod
        end

        it "should add package" do
          @changeset.add_package("pack", "prod")
          @changeset.packages.length.should == 1
        end

        it "should add erratum" do
          @changeset.add_erratum("err", "prod")
          @changeset.errata.length.should == 1
        end

        it "should add repo" do
          @changeset.add_repo("repo", "prod")
          @changeset.repos.length.should == 1
        end

      end
    end

    describe "removing content" do

      before(:each) do
        @provider = Provider.create!(:name => "provider", :provider_type => Provider::CUSTOM, :organization => @organization, :repository_url => "https://something.url/stuff")

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
        ChangesetPackage.should_receive(:destroy_all).with(:package_id => 1, :changeset_id => @changeset.id, :product_id => 1).and_return(true)
        @changeset.remove_package("pack", "prod")
      end

      it "should remove erratum" do
        ChangesetErratum.should_receive(:destroy_all).with(:errata_id => 'err', :changeset_id => @changeset.id, :product_id => 1).and_return(true)
        @changeset.remove_erratum("err", "prod")
      end

      it "should remove repo" do
        ChangesetRepo.should_receive(:destroy_all).with(:repo_id => 1, :changeset_id => @changeset.id, :product_id => 1).and_return(true)
        @changeset.remove_repo("repo", "prod")
      end

    end


    describe "promotions" do
      before(:each) do
        @provider = Provider.create!(:name => "provider", :provider_type => Provider::CUSTOM, :organization => @organization, :repository_url => "https://something.url/stuff")

        @prod = Product.new({:name => "prod"})
        @prod.provider = @provider
        @prod.environments << @organization.locker
        @prod.stub(:arch).and_return('noarch')
        @prod.stub(:promote).and_return([])
        @prod.save!
        Product.stub(:find).and_return(@prod)

        @pack = mock('Pack', {:id => 1, :name => 'pack'})
        @err  = mock('Err', {:id => 'err', :name => 'err'})

        @repo = mock('Repo', {:id => 1, :name => 'repo'})
        @repo.stub(:packages).and_return([@pack])
        @repo.stub(:errata).and_return([@err])
        @repo.stub(:promote).and_return([])
        @repo.stub(:sync).and_return([])
        @repo.stub(:has_package?).and_return(true)
        @repo.stub(:has_erratum?).and_return(true)
        @repo.stub(:is_cloned_in?).and_return(true)
        Glue::Pulp::Repo.stub(:find).and_return(@repo)

        @clone = mock('Repo', {:id => 2, :name => 'repo_clone'})
        @clone.stub(:has_package?).and_return(false)
        @clone.stub(:has_erratum?).and_return(false)
        @repo.stub(:get_clone).and_return(@clone)

        @prod.stub(:repos).and_return([@repo])

        @environment.prior.stub(:products).and_return([@prod])
        @environment.prior.products.stub(:find_by_name).and_return(@prod)

      end

      it "should fail if the product is not in the review phase" do
        lambda {@changeset.promote}.should raise_error
      end

      it "should promote products" do
        @changeset.products << @prod
        @changeset.state = Changeset::REVIEW

        @prod.should_receive(:promote).once

        @changeset.promote
      end

      it "should promote repositories" do
        @prod.environments << @environment
        @changeset.repos << ChangesetRepo.new(:repo_id => @repo.id, :display_name => 'repo', :product_id => @prod.id, :changeset => @changeset)
        @changeset.state = Changeset::REVIEW

        @repo.stub(:is_cloned_in?).and_return(false)
        @repo.should_receive(:promote).once

        @changeset.promote
      end

      it "should synchronize repositories that have been promoted" do
        @prod.environments << @environment
        @changeset.repos << ChangesetRepo.new(:repo_id => @repo.id, :display_name => @repo.name, :product_id => @prod.id, :changeset => @changeset)
        @changeset.state = Changeset::REVIEW

        @repo.stub(:is_cloned_in?).and_return(true)
        @repo.should_receive(:sync).once

        @changeset.promote
      end

      it "should promote packages" do
        @prod.environments << @environment
        @changeset.packages << ChangesetPackage.new(:package_id => @pack.id, :display_name => @pack.name, :product_id => @prod.id, :changeset => @changeset)
        @changeset.state = Changeset::REVIEW

        @clone.should_receive(:add_packages).once.with([@pack.id])

        @changeset.promote
      end

      it "should promote errata" do
        @prod.environments << @environment
        @changeset.errata << ChangesetErratum.new(:errata_id => @err.id, :display_name => @err.name, :product_id => @prod.id, :changeset => @changeset)
        @changeset.state = Changeset::REVIEW

        @clone.should_receive(:add_errata).once.with([@err.id])

        @changeset.promote
      end

    end




  end

end
