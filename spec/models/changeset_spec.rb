require 'spec_helper'
include OrchestrationHelper

describe Changeset do

  describe "Changeset should" do 
    before(:each) do
      disable_org_orchestretion


      User.current = User.find_or_create_by_username(:username => 'admin', :password => 'admin12345')
      @organization = Organization.create!(:name => 'candyroom', :cp_key => 'test_organization')
      @environment = KPEnvironment.new({:name => 'julia', :prior=>@organization.locker})  
      @organization.environments << @environment
      @organization.save!
      @environment.save!
    end   

    it "changeset should not be null" do
      @environment.should_not be_nil
      @environment.working_changesets.should_not be_nil
    end

    it "changeset first user should equal current user" do
      cs = @environment.working_changesets.first
      cu = ChangesetUser.new(:changeset => cs, :user => User.current)
      cu.save!
      cs.users.first.user_id.should == User.current.id
      cs.users.first.changeset_id.should == cs.id
    end

    it "changeset find or create should work" do
      cs = @environment.working_changesets.first
      cu = ChangesetUser.find_or_create_by_user_id_and_changeset_id(User.current.id, cs.id)
      cu.save!
      cs.users.first.user_id.should == User.current.id
      cs.users.first.changeset_id.should == cs.id
    end

    it "changeset find or create should work" do
      cs = @environment.working_changesets.first
      cu = ChangesetUser.find_or_create_by_user_id_and_changeset_id(User.current.id, cs.id)
      cu.save!
      ChangesetUser.destroy_all(:changeset_id => cs.id)
      cs.users.should be_empty
    end

  end

end
