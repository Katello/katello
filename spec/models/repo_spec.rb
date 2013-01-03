#
# Copyright 2011 Red Hat, Inc.
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
require 'helpers/repo_test_data'

describe Glue::Pulp::Repo, :katello => true do

    let(:to_create_custom) do
    {
      :name => "some name",
      :description => "a description",
      :repository_url => "https://some.url/path",
      :provider_type => Provider::CUSTOM
    }
    end

  before :each do
    disable_repo_orchestration
    disable_org_orchestration
    disable_product_orchestration

    @organization = Organization.create!(:name=>ProductTestData::ORG_ID, :label => 'admin-org-37070')

    @provider = Provider.create(to_create_custom) do |p|
      p.organization = @organization
    end

    @product1 = Product.create!({:cp_id => "product1_id",:label=>"prod1",  :name=> "product1", :productContent => [], :provider => @provider, :environments => [@organization.library]})
    ep = EnvironmentProduct.find_or_create(@organization.library, @product1)
    RepoTestData::REPO_PROPERTIES.merge!(:environment_product => ep)

    @repo = Repository.create!(RepoTestData::REPO_PROPERTIES)

    @rh_product =  Product.create!({:cp_id => "rh_product1_id", :label =>"rh_prod1", :name=> "rh_product1", :productContent => [], 
                                    :provider => @organization.redhat_provider, :environments => [@organization.library]})
    ep2 = EnvironmentProduct.find_or_create(@organization.library, @rh_product)
    @rh_repo = Repository.create!(:name=>"red hat repo", :label=>"red_hat_repo",
                                  :environment_product=>ep2, :pulp_id=>"redhat_pulp_id",
                                  :uri=>"http://redhat.com/cdn/content",
                                  :feed => 'https://localhost')

  end

  context "Create & destroy a repo" do
    it "should create the repo with correct properties" do
      Resources::Pulp::Repository.should_receive(:create).with do |props|
        props[:id].should == RepoTestData::REPO_PROPERTIES[:pulp_id]
        props[:name].should == RepoTestData::REPO_PROPERTIES[:label]
        props[:groupid].should == RepoTestData::REPO_PROPERTIES[:groupid]
        props[:arch].should == RepoTestData::REPO_PROPERTIES[:arch]
        props[:feed].should == RepoTestData::REPO_PROPERTIES[:feed]
        true
      end
      @repo.create_pulp_repo
    end

    it "should call  Pulp and candlepin's delete api on destroy for custom providers" do
      @repo.stub(:update_packages_index).and_return
      @repo.stub(:update_errata_index).and_return
      @repo.stub(:content_id).and_return("124321323")
      Resources::Candlepin::Product.should_receive(:remove_content)
      Resources::Candlepin::Content.should_receive(:destroy)
      Resources::Pulp::Repository.should_receive(:destroy).with(RepoTestData::REPO_ID)
      @repo.destroy
    end

    it "should only call Pulp's repo delete api on destroy for redhat providers" do
      @rh_repo.stub(:update_packages_index).and_return
      @rh_repo.stub(:update_errata_index).and_return
      @rh_repo.stub(:content_id).and_return("124321323")
      Resources::Pulp::Repository.stub(:find).and_return({:groupid=>["product:123", "env:123", "org:123"]})
      Resources::Candlepin::Product.should_receive(:remove_content)
      Resources::Candlepin::Content.should_not_receive(:destroy)
      Resources::Pulp::Repository.should_receive(:destroy).with(@rh_repo.pulp_id)
      @rh_repo.destroy
    end
  end

  context "Finding a repo" do
    it "should call Pulp's find api'" do
      Resources::Pulp::Repository.should_receive(:find).with(RepoTestData::REPO_ID)
      Repository.find_by_pulp_id(RepoTestData::REPO_ID).feed
    end

    it "should return new instance with correct properties" do
      repo = Repository.find_by_pulp_id(RepoTestData::REPO_ID)
      repo.pulp_id.should == RepoTestData::REPO_PROPERTIES[:pulp_id]
      repo.name.should == RepoTestData::REPO_PROPERTIES[:name]
      repo.groupid.should == RepoTestData::REPO_PROPERTIES[:groupid]
    end
  end

  context "Find packages" do
    it "should find all packages in the repo" do
      Resources::Pulp::Repository.should_receive(:packages).once.with(RepoTestData::REPO_ID)
      packs = @repo.packages
      packs.length.should == RepoTestData::REPO_PACKAGES.length
    end

    it "called for second time should use the cached values" do
      @repo.packages
      Resources::Pulp::Repository.should_not_receive(:packages).with(RepoTestData::REPO_ID, {})
      @repo.packages
    end

    it "should return correct values for has_package?" do
      @repo.has_package?(RepoTestData::REPO_PACKAGES[0][:id]).should == true
      @repo.has_package?(RepoTestData::REPO_PACKAGES[0][:id]+"X").should == false
    end
  end

  context "Find errata" do
    it "should find all errata in the repo" do
      Resources::Pulp::Repository.should_receive(:errata).once.with(RepoTestData::REPO_ID)
      errata = @repo.errata
      errata.length.should == RepoTestData::REPO_ERRATA.length
    end

    it "called for second time should use the cached values" do
      @repo.errata
      Resources::Pulp::Repository.should_not_receive(:errata).with(RepoTestData::REPO_ID)
      @repo.errata
    end

    it "should return correct values for has_erratum?" do
      @repo.has_erratum?(RepoTestData::REPO_ERRATA[0][:id]).should == true
      @repo.has_erratum?(RepoTestData::REPO_ERRATA[0][:id]+"X").should == false
    end
  end

  context "Find distributions" do
    it "should find all distributions in the repo" do
      Resources::Pulp::Repository.should_receive(:distributions).once.with(RepoTestData::REPO_ID)
      dists = @repo.distributions
      dists.length.should == RepoTestData::REPO_DISTRIBUTIONS.length
    end

    it "called for second time should use the cached values" do
      @repo.distributions
      Resources::Pulp::Repository.should_not_receive(:distributions).with(RepoTestData::REPO_ID)
      @repo.distributions
    end

    it "should return correct values for has_distribution?" do
      @repo.has_distribution?(RepoTestData::REPO_DISTRIBUTIONS[0][:id]).should == true
      @repo.has_distribution?("some-invalid-distro-id").should == false
    end
  end

  context "Synchronization" do

    it "should call pulp synchronization api" do
      @repo.stub(:async).and_return(@repo)
      Resources::Pulp::Repository.should_receive(:sync).with(RepoTestData::REPO_ID).and_return({})
      task = mock()
      task.stub(:save!)
      PulpSyncStatus.should_receive(:using_pulp_task).and_return(task)
      @repo.sync
    end

    context "status returned by synced?" do

      it "should be false for repos that have never been synced" do
        Resources::Pulp::Repository.stub(:sync_history).and_return([])
        @repo.synced?.should == false
      end

      it "should be false for repos whose last sync failed" do
        Resources::Pulp::Repository.stub(:sync_history).with(RepoTestData::REPO_ID).and_return(RepoTestData::UNSUCCESSFULL_SYNC_HISTORY)
        @repo.synced?.should == false
      end

      it "should be true for repos with last successfull sync in sync history" do
        Resources::Pulp::Repository.stub(:sync_history).with(RepoTestData::REPO_ID).and_return(RepoTestData::SUCCESSFULL_SYNC_HISTORY)
        @repo.synced?.should == true
      end
    end

    context "status returned by sync_status" do

      it "should be status of the last synchronization" do
        Resources::Pulp::Repository.stub(:sync_history).with(RepoTestData::REPO_ID).and_return(RepoTestData::SUCCESSFULL_SYNC_HISTORY)
        returned_status = @repo.sync_status

        last_status = ::PulpSyncStatus.using_pulp_task(RepoTestData::SUCCESSFULL_SYNC_HISTORY[0])

        returned_status.state.should == last_status.state
        returned_status.start_time.should == last_status.start_time
        returned_status.finish_time.should == last_status.finish_time
      end
    end

    context "state returned by sync_state" do

      it "should be the same as state of the last synchronization status" do
        Resources::Pulp::Repository.stub(:sync_history).with(RepoTestData::REPO_ID).and_return(RepoTestData::SUCCESSFULL_SYNC_HISTORY)
        @repo.sync_state.should == RepoTestData::SUCCESSFULL_SYNC_HISTORY[0][:state]
      end
    end

    context "should return correct synchronization times" do

      it "for already synced repo" do
        Resources::Pulp::Repository.stub(:sync_history).with(RepoTestData::REPO_ID).and_return(RepoTestData::SUCCESSFULL_SYNC_HISTORY)
        @repo.sync_start.to_s.should == RepoTestData::LAST_SUCC_SYNC_START
        @repo.sync_finish.to_s.should == RepoTestData::LAST_SUCC_SYNC_FINISH
      end

      it "for repo that has never been synced" do
        Resources::Pulp::Repository.stub(:sync_history).with(RepoTestData::REPO_ID).and_return([])
        @repo.sync_start.should == nil
        @repo.sync_finish.should == nil
      end
    end

    context "should properly sort sync status" do
      before(:each) do
        @finished = {
          "start_time" => "2012-03-09T12:50:18-05:00",
          "finish_time" => "2012-03-09T13:03:00-05:00",
          "state" => "finished"
        }
        @finished_2 = {
          "start_time" => "2012-03-09T14:50:18-05:00",
          "finish_time" => "2012-03-09T16:03:00-08:00",
          "state" => "finished"
        }
        @running = {
          "start_time" => "2012-03-09T12:50:18-05:00",
          "finish_time" => nil,
          "state" => "running"
        }
        @scheduled = {
          "start_time" => nil,
          "finish_time" => nil,
          "state" => "waiting",
          "scheduler" => "interval"
        }
      end
    
      it "for a single running status" do
        @repo.sort_sync_status([@running]).should == [@running]
      end
      
      it "for a single scheduled status" do
        @repo.sort_sync_status([@scheduled]).should == [@scheduled]
      end
      
      it "for a single finished status" do
        @repo.sort_sync_status([@finished]).should == [@finished]
      end

      it "for a running status and complete status" do
        @repo.sort_sync_status([@finished, @running]).should == [@running, @finished]
      end
      
      it "for a running status and a scheduled status" do
        @repo.sort_sync_status([@scheduled, @running]).should == [@running, @scheduled]
      end
      
      it "for a finished status and a scheduled status" do
        @repo.sort_sync_status([@scheduled, @finished]).should == [@finished, @scheduled]
      end

      it "for two finished and a scheduled status" do
        @repo.sort_sync_status([@finished_2, @scheduled, @finished]).should == [@finished_2, @finished, @scheduled]
      end
      
      it "for a finished, running and a scheduled status" do
        @repo.sort_sync_status([@scheduled, @running, @finished]).should == [@running, @finished, @scheduled]
      end

      it "for two finished, running and a scheduled status" do
        @repo.sort_sync_status([@finished_2, @scheduled, @running, @finished]).should == [@running, @finished_2, @finished, @scheduled]
      end

    end

    context "cancelling" do

      it "should call Pulp's cancel api if the sync history is not empty" do
        Resources::Pulp::Repository.stub(:sync_status) do
          raise
        end
        Resources::Pulp::Repository.stub(:sync_history).with(RepoTestData::REPO_ID).and_return(RepoTestData::SUCCESSFULL_SYNC_HISTORY)
        Resources::Pulp::Task.should_receive(:cancel).with(RepoTestData::SUCCESSFULL_SYNC_HISTORY[0]["id"])
        @repo.cancel_sync
      end

      it "should not call Pulp's cancel api if the sync history is empty" do
        Resources::Pulp::Repository.stub(:sync_status) do
          raise
        end
        Resources::Pulp::Repository.stub(:sync_history).with(RepoTestData::REPO_ID).and_return([])
        Resources::Pulp::Task.should_not_receive(:cancel)
        @repo.cancel_sync
      end

    end
  end


  context "Get referenced objects" do
    it "should return correct environment" do
      @repo.environment.should == @organization.library
    end

    it "should return correct organization" do
      @repo.organization.should == @organization
    end

    it "should return correct product" do
      @repo.product.should == @product1
    end

  end

  describe "Cloned repo id" do
    before do
      @to_env = KTEnvironment.create!(:name=>"Prod", :label=> "Prod", :organization => @organization, :prior => @organization.library)
    end
    it "should be composed from various attributes to be uniqe" do
      cloned_repo_id = @repo.clone_id(@to_env)
      cloned_repo_id.should == "#{@repo.organization.label}-#{@to_env.label}-#{@repo.product.label}-#{@repo.label}"
    end

  end

  context "Repo promote" do

    before :each do
      Resources::Pulp::Repository.stub(:packages).and_return([])
      Resources::Pulp::Repository.stub(:errata).and_return([])

      @to_env = KTEnvironment.create!(:organization =>@organization, :name=>"Prod",:label=>"Prod", :prior=>@organization.library)
      @from_env = @to_env.prior

      ep = EnvironmentProduct.find_or_create(@to_env, @product1)
      RepoTestData::CLONED_PROPERTIES.merge!(:environment_product => ep)

      @content_path = "/content/dist/rhel/server/5/5.1/x86_64/os"
      @repo.stub(:relative_path => "#{@organization.name}/Library#{@content_path}")

    end

    it "should sync the repo if it was already cloned" do
      @clone = Repository.create!(RepoTestData::CLONED_PROPERTIES)
      @clone.stub(:clone_id).with(@to_env).and_return(nil)
      @clone.stub(:sync)
      @repo.stub(:clone_id).with(@to_env).and_return(RepoTestData::CLONED_REPO_ID)
      @repo.stub(:get_clone).with(@to_env).and_return(@clone)

      @clone.should_receive(:sync)
      @repo.should_not_receive(:clone)

      @repo.promote(@from_env, @to_env)
    end

    it "should promote filters when promoting from Library" do
      @repo.stub(:filters).and_return([mock(RepoTestData::REPO_FILTER)])

      @repo.filter_pulp_ids_to_promote(@from_env, @to_env).should == RepoTestData::REPO_PULP_FILTER_IDS
    end

    it "should promote filters when promoting from non-Library environment" do
      @repo.stub(:filters).and_return([mock(RepoTestData::REPO_FILTER)])
      @from_env.stub(:library?).and_return(false)

      @repo.filter_pulp_ids_to_promote(@from_env, @to_env).should == []
    end

    it "should clone the repo" do
      Resources::Pulp::Repository.should_receive(:clone_repo).with do |repo, cloned|
        repo.should == @repo
        cloned.name.should == RepoTestData::CLONED_PROPERTIES[:name]

        group_id = [
          "product:"+@repo.product.cp_id.to_s,
          "env:"+@to_env.id.to_s,
          "org:"+ @to_env.organization.id.to_s
        ]
        cloned.groupid.should == group_id
        cloned.arch.should == RepoTestData::CLONED_PROPERTIES[:arch]
        cloned.feed.should == RepoTestData::CLONED_PROPERTIES[:feed]
        true
      end
      @repo.promote(@from_env, @to_env)
    end

    it "should return correct is_cloned_in? status" do
      @clone = Repository.create!(RepoTestData::CLONED_PROPERTIES)
      @clone.stub(:clone_id).with(@to_env).and_return(nil)
      @repo.stub(:clone_id).with(@to_env).and_return(RepoTestData::CLONED_REPO_ID)

      @clone.is_cloned_in?(@to_env).should == false
      @repo.is_cloned_in?(@to_env).should == true
    end

    it "should be able to return the clone" do
      @clone = Repository.create!(RepoTestData::CLONED_PROPERTIES)
      @repo.stub(:clone_id).with(@to_env).and_return(RepoTestData::CLONED_REPO_ID)
      clone = @repo.get_clone(@to_env)
      clone.pulp_id.should == RepoTestData::CLONED_PROPERTIES[:pulp_id]
    end

    it "should set relative path correctly" do
      Resources::Pulp::Repository.should_receive(:clone_repo).with do |repo, cloned|
        cloned.relative_path.should == "#{@repo.organization.name}/#{@to_env.name}#{@content_path}"
        true
      end
      @repo.promote(@from_env, @to_env)
    end
  end

  describe "#package_groups" do
    before { Resources::Pulp::PackageGroup.stub(:all => RepoTestData.repo_package_groups) }
    it "should call pulp layer" do
      Resources::Pulp::PackageGroup.should_receive(:all).with(RepoTestData::REPO_PROPERTIES[:pulp_id])
      @repo.package_groups
    end

    it "should find a repo by attr" do
      @repo.package_groups(:name => "katello").should_not be_empty
      @repo.package_groups(:name => "non-existing").should be_empty
    end
  end

  describe "#package_group_categories" do
    before { Resources::Pulp::PackageGroupCategory.stub(:all => RepoTestData.repo_package_group_categories) }
    it "should call pulp layer" do
      Resources::Pulp::PackageGroupCategory.should_receive(:all).with(RepoTestData::REPO_PROPERTIES[:pulp_id])
      @repo.package_group_categories
    end

    it "should find a repo by attr" do
      @repo.package_group_categories(:name => "Development").should_not be_empty
      @repo.package_group_categories(:name => "non-existing").should be_empty
    end
  end

end
