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
        @view = FactoryGirl.create(:content_view, :organization => @organization)
        @changeset.stub_chain(:environment, :prior) do
          mock(:env,
               :content_views => mock(:include? => false)
              )
        end
      end

      it "should fail on add view" do
        lambda { @changeset.add_content_view!(@view) }.should raise_error(Errors::ChangesetContentException)
      end
    end

    describe "promotions" do
      before(:each) do
        @changeset.stub(:wait_for_tasks).and_return(nil)
        @changeset.stub(:affected_repos).and_return([])
      end

      it "should update env content" do
        @changeset.state = Changeset::REVIEW
        @content_view_environment = @environment.content_view_environment
        @environment.stub(:content_view_environment).and_return(@content_view_environment)
        @content_view_environment.should_receive(:update_cp_content)
        @changeset.apply(:async => false)
      end

      it "should have correct state after successful promotion" do
        @changeset.state = Changeset::REVIEW
        @changeset.apply(:async => false)
        @changeset.state.should == Changeset::PROMOTED
      end

      it "should have correct state after unsuccessful promotion" do
        @changeset.state = Changeset::REVIEW
        @changeset.stub(:promote_views).and_raise(StandardError)
        lambda { @changeset.apply(:async => false) }.should raise_exception
        @changeset.state.should == Changeset::FAILED
      end

    end
  end
end
