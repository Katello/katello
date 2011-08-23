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

describe Glue::Pulp::Repo do

  before :each do
    disable_repo_orchestration

    @repo = Glue::Pulp::Repo.new(RepoTestData::REPO_PROPERTIES)
  end

  context "Create & destroy a repo" do
    it "should create the repo with correct properties" do
      Pulp::Repository.should_receive(:create).with do |props|
        props[:id].should == RepoTestData::REPO_PROPERTIES[:id]
        props[:name].should == RepoTestData::REPO_PROPERTIES[:name]
        props[:groupid].should == RepoTestData::REPO_PROPERTIES[:groupid]
        props[:arch].should == RepoTestData::REPO_PROPERTIES[:arch]
        props[:feed].should == RepoTestData::REPO_PROPERTIES[:feed]
        true
      end
      @repo.create
    end

    it "should call the Pulp's delete api on destroy" do
      Pulp::Repository.should_receive(:destroy).with(RepoTestData::REPO_ID)
      @repo.destroy
    end
  end

  context "Finding a repo" do
    it "should call Pulp's find api'" do
      Pulp::Repository.should_receive(:find).with(RepoTestData::REPO_ID)
      Glue::Pulp::Repo.find(RepoTestData::REPO_ID)
    end

    it "should return new instance with correct properties" do
      repo = Glue::Pulp::Repo.find(RepoTestData::REPO_ID)
      repo.id.should == RepoTestData::REPO_PROPERTIES[:id]
      repo.name.should == RepoTestData::REPO_PROPERTIES[:name]
      repo.groupid.should == RepoTestData::REPO_PROPERTIES[:groupid]
    end
  end

  context "Find packages" do
    it "should find all packages in the repo" do
      Pulp::Repository.should_receive(:packages).once.with(RepoTestData::REPO_ID)
      packs = @repo.packages
      packs.length.should == RepoTestData::REPO_PACKAGES.length
    end

    it "called for second time should use the cached values" do
      @repo.packages
      Pulp::Repository.should_not_receive(:packages).with(RepoTestData::REPO_ID)
      @repo.packages
    end

    it "should return correct values for has_package?" do
      @repo.has_package?(RepoTestData::REPO_PACKAGES[0][:id]).should == true
      @repo.has_package?(RepoTestData::REPO_PACKAGES[0][:id]+"X").should == false
    end
  end

  context "Find errata" do
    it "should find all errata in the repo" do
      Pulp::Repository.should_receive(:errata).once.with(RepoTestData::REPO_ID)
      errata = @repo.errata
      errata.length.should == RepoTestData::REPO_ERRATA.length
    end

    it "called for second time should use the cached values" do
      @repo.errata
      Pulp::Repository.should_not_receive(:errata).with(RepoTestData::REPO_ID)
      @repo.errata
    end

    it "should return correct values for has_erratum?" do
      @repo.has_erratum?(RepoTestData::REPO_ERRATA[0][:id]).should == true
      @repo.has_erratum?(RepoTestData::REPO_ERRATA[0][:id]+"X").should == false
    end
  end

  context "Find distributions" do
    it "should find all distributions in the repo" do
      Pulp::Repository.should_receive(:distributions).once.with(RepoTestData::REPO_ID)
      dists = @repo.distributions
      dists.length.should == RepoTestData::REPO_DISTRIBUTIONS.length
    end

    it "called for second time should use the cached values" do
      @repo.distributions
      Pulp::Repository.should_not_receive(:distributions).with(RepoTestData::REPO_ID)
      @repo.distributions
    end
  end

  context "Synchronization" do

    it "should call pulp synchronization api" do
      Pulp::Repository.should_receive(:sync).with(RepoTestData::REPO_ID)
      @repo.sync
    end

    context "status returned by synced?" do

      it "should be false for repos that have never been synced" do
        Pulp::Repository.stub(:sync_history).and_return([])
        @repo.synced?.should == false
      end

      it "should be false for repos whose last sync failed" do
        Pulp::Repository.stub(:sync_history).with(RepoTestData::REPO_ID).and_return(RepoTestData::UNSUCCESSFULL_SYNC_HISTORY)
        @repo.synced?.should == false
      end

      it "should be true for repos with last successfull sync in sync history" do
        Pulp::Repository.stub(:sync_history).with(RepoTestData::REPO_ID).and_return(RepoTestData::SUCCESSFULL_SYNC_HISTORY)
        @repo.synced?.should == true
      end
    end

    context "status returned by sync_status" do

      it "should be status of the last synchronization" do
        Pulp::Repository.stub(:sync_history).with(RepoTestData::REPO_ID).and_return(RepoTestData::SUCCESSFULL_SYNC_HISTORY)
        returned_status = @repo.sync_status

        last_status = ::PulpSyncStatus.using_pulp_task(RepoTestData::SUCCESSFULL_SYNC_HISTORY[0])

        returned_status.state.should == last_status.state
        returned_status.start_time.should == last_status.start_time
        returned_status.finish_time.should == last_status.finish_time
      end
    end

    context "state returned by sync_state" do

      it "should be the same as state of the last synchronization status" do
        Pulp::Repository.stub(:sync_history).with(RepoTestData::REPO_ID).and_return(RepoTestData::SUCCESSFULL_SYNC_HISTORY)
        @repo.sync_state.should == RepoTestData::SUCCESSFULL_SYNC_HISTORY[0][:state]
      end
    end

    context "should return correct synchronization times" do

      it "for already synced repo" do
        Pulp::Repository.stub(:sync_history).with(RepoTestData::REPO_ID).and_return(RepoTestData::SUCCESSFULL_SYNC_HISTORY)
        @repo.sync_start.to_s.should == RepoTestData::LAST_SUCC_SYNC_START
        @repo.sync_finish.to_s.should == RepoTestData::LAST_SUCC_SYNC_FINISH
      end

      it "for repo that has never been synced" do
        Pulp::Repository.stub(:sync_history).with(RepoTestData::REPO_ID).and_return([])
        @repo.sync_start.should == nil
        @repo.sync_finish.should == nil
      end
    end

    context "cancelling" do

      it "should call Pulp's cancel api if the sync history is not empty" do
        Pulp::Repository.stub(:sync_history).with(RepoTestData::REPO_ID).and_return(RepoTestData::SUCCESSFULL_SYNC_HISTORY)
        Pulp::Repository.should_receive(:cancel)
        @repo.cancel_sync
      end

      it "should call Pulp's cancel api if the sync history is empty" do
        Pulp::Repository.stub(:sync_history).with(RepoTestData::REPO_ID).and_return([])
        Pulp::Repository.should_not_receive(:cancel)
        @repo.cancel_sync
      end

    end
  end


  context "Get referenced objects" do

    before :each do
      stub_reference_objects
    end

    it "should return correct environment" do
      @repo.environment.should == @env
    end

    it "should return correct organization" do
      @repo.organization.should == @org
    end

    it "should return correct product" do
      @repo.product.should == @product
    end

  end


  context "Repo promote" do

    before :each do
      stub_reference_objects
      @locker = mock(KPEnvironment, {:id => RepoTestData::REPO_ENV_ID, :name => 'Locker'})
      @locker.stub(:organization).and_return(@org)
      @to_env = mock(KPEnvironment, {:id => RepoTestData::CLONED_REPO_ENV_ID, :name => 'Prod'})
      @to_env.stub(:organization).and_return(@org)
      @product.stub(:locker).and_return(@locker)

      @clone = Glue::Pulp::Repo.new(RepoTestData::CLONED_PROPERTIES)

      Glue::Pulp::Repos.stub(:clone_repo_id).with(@repo, @to_env).and_return(RepoTestData::CLONED_REPO_ID)
      Glue::Pulp::Repos.stub(:clone_repo_id).with(@clone, @to_env).and_return(RepoTestData::CLONED_2_REPO_ID)

    end

    it "should clone the repo" do
      Pulp::Repository.should_receive(:clone_repo).with do |repo, cloned|
        repo.should == @repo
        cloned.id.should == RepoTestData::CLONED_PROPERTIES[:id]
        cloned.name.should == RepoTestData::CLONED_PROPERTIES[:name]
        cloned.groupid.should == RepoTestData::CLONED_PROPERTIES[:groupid]
        cloned.arch.should == RepoTestData::CLONED_PROPERTIES[:arch]
        cloned.feed.should == RepoTestData::CLONED_PROPERTIES[:feed]
        true
      end
      @repo.promote(@to_env, @product)
    end

    it "should retrurn correct is_cloned_in? status" do
      @clone.is_cloned_in?(@to_env).should == false
      @repo.is_cloned_in?(@to_env).should == true
    end

    it "should be able to retrurn the clone" do
      clone = @repo.get_clone(@to_env)
      clone.id.should == RepoTestData::CLONED_PROPERTIES[:id]
    end

    it "should set relative path correctly" do
      Pulp::Repository.should_receive(:clone_repo).with do |repo, cloned|
        cloned.relative_path.should == "Corp/Prod/Ruby/repo"
        true
      end
      @repo.promote(@to_env, @product)
    end
  end

end


def disable_repo_orchestration
  Pulp::Repository.stub(:sync_history).and_return([])

  Pulp::Repository.stub(:packages).with(RepoTestData::REPO_ID).and_return(RepoTestData::REPO_PACKAGES)
  Pulp::Repository.stub(:errata).with(RepoTestData::REPO_ID).and_return(RepoTestData::REPO_ERRATA)
  Pulp::Repository.stub(:distributions).with(RepoTestData::REPO_ID).and_return(RepoTestData::REPO_DISTRIBUTIONS)
  Pulp::Repository.stub(:find).with(RepoTestData::REPO_ID).and_return(RepoTestData::REPO_PROPERTIES)
  Pulp::Repository.stub(:find).with(RepoTestData::CLONED_REPO_ID).and_return(RepoTestData::CLONED_PROPERTIES)
end

def stub_reference_objects
  @org = mock(Organization, {:id => RepoTestData::REPO_ORG_ID, :name => "Corp"})
  Organization.stub(:find).with(RepoTestData::REPO_ORG_ID).and_return(@org)

  @env = mock(KPEnvironment, {:id => RepoTestData::REPO_ENV_ID, :name => "Dev"})
  KPEnvironment.stub(:find).with(RepoTestData::REPO_ENV_ID).and_return(@env)
 
  @product = mock(Product, {:id => RepoTestData::REPO_PRODUCT_ID, :cp_id => RepoTestData::REPO_PRODUCT_CP_ID, :name => "Ruby"})
  Product.stub(:find).with(RepoTestData::REPO_PRODUCT_ID).and_return(@product)
  Product.stub("find_by_cp_id!").with(RepoTestData::REPO_PRODUCT_CP_ID.to_s).and_return(@product)
end
