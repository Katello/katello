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
include OrchestrationHelper

describe Changeset, :katello => true do

  describe "Changeset should" do
    before(:each) do
      disable_org_orchestration
      disable_product_orchestration
      disable_user_orchestration

      User.current  = User.find_or_create_by_username(:username => 'admin', :password => 'admin12345')
      @organization = Organization.create!(:name=>'candyroom', :label => 'test_organization')
      @environment  = KTEnvironment.create!(:name=>'julia', :label=> 'julia', :prior => @organization.library,
                                            :organization => @organization)
      @changeset    = PromotionChangeset.create!(:environment => @environment, :name => "foo-changeset")
      Repository.any_instance.stub(:content).and_return(Candlepin::Content.new(:type=>'yum'))
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

    it "changeset json should contain the types" do
      json = JSON.load(@changeset.to_json)
      json['action_type'].should_not be_nil
    end

    describe "scopes" do
      before do
        @promoting = PromotionChangeset.create!(:environment => @environment,
                                                :name        => "bar-changeset",
                                                :state       => Changeset::PROMOTING)
        @deleting  = DeletionChangeset.create!(:environment => @environment,
                                               :name        => "baz-changeset",
                                               :state       => Changeset::DELETING)
      end

      describe ".with_state" do
        it "should find right changesets" do
          Changeset.with_state(Changeset::DELETED).should be_empty
          Changeset.with_state(Changeset::NEW).size.should eql(1)
          Changeset.with_state(Changeset::PROMOTING).size.should eql(1)
          Changeset.with_state(Changeset::NEW, Changeset::PROMOTING).size.should eql(2)
          Changeset.with_state(Changeset::DELETED,
                               Changeset::NEW,
                               Changeset::PROMOTING).size.should eql(2)
        end
      end

      describe ".started" do
        subject { Changeset.started }
        its(:size) { should eql(2) }
        it { should include(@promoting, @deleting) }
      end

      describe ".colliding(changeset)" do
        before do
          @alpha      = KTEnvironment.create!(:name         => 'alpha', :label => 'alpha',
                                              :prior        => @environment,
                                              :organization => @organization)
          @beta       = KTEnvironment.create!(:name         => 'beta', :label => 'beta',
                                              :prior        => @organization.library,
                                              :organization => @organization)
          @collision = PromotionChangeset.create!(:environment => @alpha,
                                                   :name        => "collision1")
          @no_collision = PromotionChangeset.create!(:environment => @beta,
                                                   :name        => "nocollision1")
        end

        it 'should detect "identical" collision' do
          Changeset.colliding(@promoting).should include(@deleting)
        end

        it 'should detect "following" collision' do
          Changeset.colliding(@promoting).should include(@collision)
        end

        it 'should detect "previous" collision' do
          Changeset.colliding(@collision).should include(@promoting)
        end

        it 'should ignore other cases' do
          Changeset.colliding(@promoting).should_not include(@no_collision) # only same start
          Changeset.colliding(@collision).should_not include(@no_collision) # nothing in common
        end
      end
    end

    describe "fail adding content not contained in the prior environment" do
      before do
        @provider      = Provider.create!(:name         => "provider", :provider_type => Provider::CUSTOM,
                                          :organization => @organization, :repository_url => "https://something.url/stuff")
        @repo          = mock(:repo, :find_packages_by_name => [])
        @prod          = Product.new({:name=>"prod" , :label=> "prod" })
        @prod.provider = @provider
        @prod.environments << @organization.library
        @prod.stub(:arch).and_return('noarch')
        @prod.stub(:repos).and_return([@repo])
        @prod.stub(:has_erratum?).and_return(false)
        @changeset.stub_chain(:environment, :prior) do
          mock(:env,
               :products     => mock(:products, :include? => false, :any? => false),
               :repositories => [])
        end
        @prod.save!
        Runcible::Extensions::Errata.stub(:find).and_return({:id=>'errata-unit-id', :errata_id=>'err'})
      end

      it "should fail on add product" do
        lambda { @changeset.add_product!(@prod) }.should raise_error(Errors::ChangesetContentException)
      end

      it "should fail on add package" do
        lambda { @changeset.add_package!("pack", @prod) }.should raise_error(Errors::ChangesetContentException)
      end

      it "should fail on add erratum" do
        lambda { @changeset.add_erratum!(Errata.new(:errata_id=>"err"), @prod) }.should raise_error(Errors::ChangesetContentException)
      end

      it "should fail on add repo" do
        lambda { @changeset.add_repository!("repo") }.should raise_error(Errors::ChangesetContentException)
      end

      it "should fail on add repo" do
        lambda { @changeset.add_distribution!("distro-id", @prod) }.should raise_error(Errors::ChangesetContentException)
      end
    end


    describe "adding content" do
      before(:each) do
        Runcible::Extensions::Repository.stub(:create).and_return({})

        @provider = Provider.create!(:name         => "provider", :provider_type => Provider::CUSTOM,
                                     :organization => @organization, :repository_url => "https://something.url/stuff")


        @prod = Product.new({:name=>"prod" , :label=> "prod" })

        @prod.provider = @provider
        @prod.environments << @organization.library
        @prod.stub(:arch).and_return('noarch')
        @prod.save!
        ep            = EnvironmentProduct.find_or_create(@organization.library, @prod)
        @pack_name    = "pack"
        @pack_version = "0.1"
        @pack_release = "1"
        @pack_arch    = "noarch"
        @pack_nvre    = @pack_name +"-"+ @pack_version +"-"+ @pack_release +"."+ @pack_arch
        @pack         = Package.new({
            :_id      => 1,
            :name    => @pack_name,
            :version => @pack_version,
            :release => @pack_release,
            :arch    => @pack_arch
        }.with_indifferent_access)
        @err          = mock('Err', { :id => 'errata-unit-id', :errata_id=>'err', :name => 'err' })

        @repo = Repository.create!(:environment_product => ep, :name => "testrepo",
                                 :label => "testrepo_label", :pulp_id=>"1010",
                                 :content_id=>'123', :relative_path=>"/foo/",
                                 :content_view_version=>ep.environment.default_content_view_version,
                                 :feed => 'https://localhost')

        @distribution = mock('Distribution', { :id => 'some-distro-id' })
        @repo.stub(:distributions).and_return([@distribution])
        @repo.stub_chain(:distributions, :index).and_return([@distribution])
        @repo.stub(:packages).and_return([@pack])
        @repo.stub(:errata).and_return([@err])
        @repo.stub(:has_package?).with(1).and_return(true)
        @repo.stub(:has_erratum?).with('err').and_return(true)
        @repo.stub(:has_distribution?).with('some-distro-id').and_return(true)
        @repo.stub(:clone_ids).and_return([])
        Product.stub(:find).and_return(@prod)
        @changeset.stub(:find_package_data).and_return(@pack)

        @prod.stub(:repos).and_return([@repo])
        @prod.stub_chain(:repos, :where).and_return([@repo])
        @environment.prior.stub(:products).and_return([@prod])
        @environment.prior.products.stub(:find_by_name).and_return(@prod)
        @environment.prior.products.stub(:find_by_cp_id).and_return(@prod)

        ChangesetDistribution.any_instance.stub(:product).and_return(@prod)
        ChangesetErratum.any_instance.stub(:product).and_return(@prod)
        ChangesetPackage.any_instance.stub(:product).and_return(@prod)

        Errata.stub(:find_by_errata_id).and_return(@err)
      end


      describe "fail adding content from not promoted product" do

        before(:each) do
          @repo.stub(:is_cloned_in?).and_return(true)
        end

        it "should fail on add package" do
          @environment.prior.stub(:products).and_return([])
          lambda { @changeset.add_package!("pack", @prod) }.should raise_error(Errors::ChangesetContentException)
        end

        it "should fail on add erratum" do
          @prod.stub(:has_erratum?).and_return(false)
          lambda { @changeset.add_erratum!(Errata.new(:errata_id=>"err"), @prod) }.should raise_error(Errors::ChangesetContentException)
        end

        it "should fail on add repo" do
          @environment.stub_chain(:prior, :repositories, :include?) { false }
          lambda { @changeset.add_repository!(@repo) }.should raise_error(Errors::ChangesetContentException)
        end

        it "should fail on add distribution" do
          @changeset.stub_chain(:environment, :prior, :repositories, :any?).and_return { false }
          lambda { @changeset.add_distribution!("some_distro_id", @prod) }.should raise_error(Errors::ChangesetContentException)
        end
      end

      describe "fail adding content from not promoted repository" do

        before(:each) do
          @prod.environments << @environment
          @repo.stub(:is_cloned_in?).and_return(false)
        end

        it "should fail on add package" do
          lambda { @changeset.add_package!("pack", @prod) }.
              should raise_error(ActiveRecord::RecordInvalid, /has not been promoted/)
        end

        it "should fail on add erratum" do
          lambda { @changeset.add_erratum!(Errata.new(:errata_id=>"err"), @prod) }.
              should raise_error(ActiveRecord::RecordInvalid, /has not been promoted/)
        end

        it "should fail on add distribution" do
          @changeset.stub_chain(:environment, :prior, :repositories, :any?).and_return { true }
          lambda { @changeset.add_distribution!("some-distro-id", @prod) }.
              should raise_error(ActiveRecord::RecordInvalid, /has not been promoted/)
        end
      end

      describe "adding content from the prior environment" do

        before(:each) do
          @prod.environments << @environment
          @repo.stub(:is_cloned_in?).and_return(true)
          @repo.stub(:last_sync).and_return("2011-11-11 11:11")
        end

        it "should add product" do
          @changeset.add_product!(@prod)
          @changeset.products.should include @prod
        end

        it "should add package by nvre" do
          @prod.stub(:find_packages_by_nvre).with(
              @changeset.environment.prior, @pack_name, @pack_version, @pack_release, nil).and_return([@pack])
          @changeset.add_package!(@pack_nvre, @prod)
          @changeset.packages.length.should == 1
          lambda { @changeset.add_package!(@pack_nvre, @prod) }.
              should raise_error(ActiveRecord::RecordInvalid, /already been taken/)
        end

        it "should add package by name" do
          @prod.stub(:find_packages_by_name).with(@changeset.environment.prior, @pack_name).and_return([@pack])
          @changeset.add_package!(@pack_name, @prod)
          @changeset.packages.length.should == 1
        end

        it "should add erratum" do
          @changeset.add_erratum!(Errata.new(:errata_id=>"err"), @prod)
          @changeset.errata.length.should == 1
          lambda { @changeset.add_erratum!(Errata.new(:errata_id=>"err"), @prod) }.
              should raise_error(ActiveRecord::RecordInvalid, /already been taken/)
        end

        it "should add repo" do
          @changeset.add_repository!(@repo)
          @changeset.repos.length.should == 1
        end

        it "should add distribution" do
          @changeset.environment.stub_chain(:prior, :repositories, :any?).and_return { true }
          @changeset.add_distribution!("some-distro-id", @prod)
          @changeset.distributions.length.should == 1
          lambda { @changeset.add_distribution!("some-distro-id", @prod) }.
              should raise_error(ActiveRecord::RecordInvalid, /already been taken/)
        end

      end

    end

    describe "removing content" do

      before(:each) do
        @provider = Provider.create!(:name => "provider", :provider_type => Provider::CUSTOM, :organization => @organization, :repository_url => "https://something.url/stuff")

        @prod          = Product.new({:name=>"prod", :label=> "prod", :cp_id => "prod" })
        @prod.provider = @provider
        @prod.environments << @organization.library
        @prod.environments << @environment
        @prod.stub(:arch).and_return('noarch')
        @prod.save!

        ep            = EnvironmentProduct.find_or_create(@organization.library, @prod)
        @pack_name    = "pack"
        @pack_version = "0.1"
        @pack_release = "1"
        @pack_arch    = "noarch"
        @pack_nvre    = @pack_name +"-"+ @pack_version +"-"+ @pack_release +"."+ @pack_arch
        @pack         = { :id => 1, :name => @pack_name }.with_indifferent_access
        @err          = mock('Err', { :id => 'errata-unit-id', :errata_id=>'err', :name => 'err' })
        @repo = Repository.new(:environment_product => ep, :name => "repo", :label => "repo_label",
                                   :pulp_id => "1343", :content_id=>'23423', :relative_path=>'/foobar/',
                                   :content_view_version=>ep.environment.default_content_view_version,
                                   :feed=>"http://localhost.com/foo/")
        @repo.stub(:create_pulp_repo).and_return([])
        @repo.save!
        @distribution = mock('Distribution', { :id => 'some-distro-id' })
        @repo.stub(:distributions).and_return([@distribution])
        @repo.stub(:packages).and_return([@pack])
        @repo.stub(:errata).and_return([@err])
        @repo.stub(:clone_ids).and_return([])

        @prod.stub(:repos).and_return([@repo])
        @prod.stub_chain(:repos, :where).and_return([@repo])

        @changeset.products = [@prod]
        @changeset.products.stub(:find_by_cp_id).and_return(@prod)

        @environment.prior.stub(:products).and_return([@prod])
        @environment.prior.products.stub(:find_by_name).and_return(@prod)
        @environment.prior.products.stub(:find_by_cp_id).and_return(@prod)
      end

      it "should remove product" do
        @changeset.products.should_receive(:delete).with(@prod).and_return(true)
        @changeset.remove_product!(@prod)
      end

      it "should remove package" do
        @prod.stub(:find_packages_by_nvre).
            with(@changeset.environment.prior, @pack_name, @pack_version, @pack_release, nil).and_return([@pack])
        ChangesetPackage.should_receive(:destroy_all).
            with(:nvrea => @pack_nvre, :changeset_id => @changeset.id, :product_id => @prod.id).and_return(true)
        @changeset.remove_package!(@pack_nvre, @prod)
      end

      it "should remove erratum" do
        ChangesetErratum.should_receive(:destroy_all).
            with(:display_name => 'err', :changeset_id => @changeset.id, :product_id => @prod.id).and_return(true)
        @changeset.remove_erratum!(Errata.new(:errata_id=>"err"), @prod)
      end

      it "should remove repo" do
        @changeset.repos.should_receive(:delete).with(@repo).and_return(true)
        @changeset.remove_repository!(@repo)
      end

      it "should remove distribution" do
        ChangesetDistribution.should_receive(:destroy_all).
            with(:distribution_id => 'some-distro-id', :changeset_id => @changeset.id, :product_id => @prod.id).
            and_return(true)
        @changeset.remove_distribution!('some-distro-id', @prod)
      end
    end


    describe "promotions" do
      before(:each) do
        @provider = Provider.create!(:name         => "provider", :provider_type => Provider::CUSTOM,
                                     :organization => @organization, :repository_url => "https://something.url/stuff")

        @prod          = Product.new({:name=>"prod" , :label=> "prod" })
        @prod.provider = @provider
        @prod.environments << @organization.library
        @prod.stub(:arch).and_return('noarch')
        @prod.stub(:apply).and_return([])
        @prod.save!
        Product.stub(:find).and_return(@prod)

        @pack         = mock('Pack', { :id => 1, :name => 'pack' })
        @err          = mock('Err', { :id => 'asdfasdf', :name => 'err' , :errata_id=>'err'})
        @distribution = mock('Distribution', { :id => 'some-distro-id' })
        ep            = EnvironmentProduct.find_or_create(@organization.library, @prod)
        @repo         = Repository.new(:environment_product => ep, :name => 'repo', :label => 'repo_label',
                                           :pulp_id => "test_pulp_id", :relative_path=>"/foo/", :content_id=>'aasfd',
                                           :content_view_version=>ep.environment.default_content_view_version,
                                           :pulp_id => "test_pulp_id", :relative_path=>"/foo/",
                                           :content_id=>'aasfd', :feed=>'https://localhost.com/foo/')

        @repo.stub(:create_pulp_repo).and_return([])
        @repo.save!
        @repo.stub_chain(:distributions, :index).and_return([@distribution])
        @repo.stub(:distributions).and_return([@distribution])
        @repo.stub(:packages).and_return([@pack])
        @repo.stub(:errata).and_return([@err])
        @repo.stub(:apply).and_return([])
        @repo.stub(:sync).and_return([])
        @repo.stub(:has_package?).and_return(true)
        @repo.stub(:has_erratum?).and_return(true)
        @repo.stub(:has_distribution?).with('some-distro-id').and_return(true)

        @repo.stub(:is_cloned_in?).and_return(true)
        @repo.stub(:clone_ids).and_return([])
        Repository.stub(:find_by_pulp_id).and_return(@repo)


        @clone = mock('Repo', { :id => 2, :name => 'repo_clone' })
        @clone.stub(:has_package?).and_return(false)
        @clone.stub(:has_erratum?).and_return(false)
        @clone.stub(:has_distribution?).and_return(false)
        @clone.stub(:generate_metadata).and_return({ })
        PulpTaskStatus.stub(:wait_for_tasks)

        @repo.stub(:clone_ids).and_return([])
        @repo.stub(:get_clone).and_return(@clone)
        @repo.stub(:get_cloned_in).and_return(nil)
        @prod.stub(:repos).and_return([@repo])
        @prod.stub(:repos).and_return([@repo])
        @prod.stub_chain(:repos, :where).and_return([@repo])

        @clone.stub(:index_packages).and_return()
        @clone.stub(:index_errata).and_return()
        @clone.stub(:index_package_groups).and_return()
        @repo.stub(:index_packages).and_return()
        @repo.stub(:index_errata).and_return()
        @repo.stub(:index_package_groups).and_return()

        @environment.prior.stub(:products).and_return([@prod])
        @environment.prior.products.stub(:find_by_name).and_return(@prod)
        @changeset.stub(:wait_for_tasks).and_return(nil)
        @changeset.stub(:calc_dependencies).and_return([])
        @changeset.stub(:affected_repos).and_return([@repo])


        Glue::Pulp::Package.stub(:index_packages).and_return(true)
        Glue::Pulp::Errata.stub(:index_errata).and_return(true)
        Glue::Pulp::PackageGroup.stub(:index_package_groups).and_return(true)
        Glue::Pulp::Repo.stub(:add_repo_packages)

        ChangesetDistribution.any_instance.stub(:product).and_return(@prod)
        ChangesetErratum.any_instance.stub(:product).and_return(@prod)
        ChangesetPackage.any_instance.stub(:product).and_return(@prod)
      end

      it "should fail if the product is not in the review phase" do
        lambda { @changeset.apply }.should raise_error(RuntimeError, /because it is not in the review phase./)
      end

      it "should promote products" do
        @changeset.products << @prod
        @changeset.state = Changeset::REVIEW

        @prod.should_receive(:promote).once
        @changeset.should_receive(:index_repo_content).once

        @changeset.apply(:async => false)
      end

      it "should promote repositories" do
        @prod.environments << @environment
        @changeset.state = Changeset::REVIEW

        #is cloned in needs to be false so that it will 'try'
        #  to clone the repo
        @repo.stub(:is_cloned_in?).and_return(false)
        #get clone needs to return the clone though, so we can
        #  generate the metadata
        @repo.stub(:get_clone).and_return(@clone) #
        @changeset.stub(:repos).and_return([@repo])
        @repo.should_receive(:promote).once
        @changeset.should_receive(:index_repo_content).once

        @changeset.apply(:async => false)
      end

      it "should update env content" do
        @changeset.state = Changeset::REVIEW
        @content_view_environment = @environment.content_view_environment
        @environment.stub(:content_view_environment).and_return(@content_view_environment)
        @content_view_environment.should_receive(:update_cp_content)
        @changeset.apply(:async => false)
      end

      it "should promote packages" do
        @prod.environments << @environment
        @changeset.packages << ChangesetPackage.new(
            :package_id => @pack.id, :display_name => @pack.name, :product_id => @prod.id, :changeset => @changeset,
            :nvrea      => 'some_nvrea')
        @changeset.state = Changeset::REVIEW

        @clone.should_receive(:add_packages).once.with([@pack.id])
        Package.should_receive(:index_packages)

        @changeset.apply(:async => false)
      end

      it "should promote errata" do
        @prod.environments << @environment
        @changeset.errata << ChangesetErratum.new(:errata_id  => @err.id, :display_name => @err.errata_id,
                                                  :product_id => @prod.id, :changeset => @changeset)
        @changeset.state = Changeset::REVIEW

        @clone.should_receive(:add_errata).once.with([@err.id])
        Errata.should_receive(:index_errata)

        @changeset.apply(:async => false)
      end

      it "should promote distributions" do
        @prod.environments << @environment
        @changeset.distributions <<
            ChangesetDistribution.new(:distribution_id => @distribution.id, :display_name => @distribution.id,
                                      :product_id      => @prod.id, :changeset => @changeset)
        @changeset.state = Changeset::REVIEW

        @clone.should_receive(:add_distribution).once.with(@distribution.id)

        @changeset.apply(:async => false)
      end

      it "should regenerate metadata of changed repos" do
        @changeset.stub(:affected_repos).and_return([@repo])
        @clone.should_receive(:generate_metadata)
        PulpTaskStatus.stub(:wait_for_tasks)
        @changeset.state = Changeset::REVIEW

        @changeset.apply(:async => false)
      end

      it "should have correct state after successful promotion" do
        @changeset.state = Changeset::REVIEW
        @changeset.apply(:async => false)
        @changeset.state.should == Changeset::PROMOTED
      end

      it "should have correct state after unsuccessful promotion" do
        @changeset.state = Changeset::REVIEW
        @changeset.stub(:promote_products).and_raise(StandardError)
        lambda { @changeset.apply(:async => false) }.should raise_exception
        @changeset.state.should == Changeset::FAILED
      end

    end
  end
end
