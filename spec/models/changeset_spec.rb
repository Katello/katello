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

require 'katello_test_helper'

module Katello
describe Changeset, :katello => true do
  include OrchestrationHelper

  describe "Changeset should" do
    before(:each) do
      disable_org_orchestration
      disable_product_orchestration
      disable_user_orchestration

      User.current  = users(:admin)
      @organization = get_organization
      @environment  = katello_environments(:dev)
      @changeset    = PromotionChangeset.create!(:environment => @environment, :name => "foo-changeset")
    end

    it "changeset should not be null" do
      @environment.wont_be_nil
      @environment.working_changesets.wont_be_nil
    end

    it "changeset first user should equal current user" do
      cu = ChangesetUser.new(:changeset => @changeset, :user => User.current)
      cu.save!
      @changeset.users.first.user_id.must_equal(User.current.id)
      @changeset.users.first.changeset_id.must_equal(@changeset.id)
    end

    it "changeset find or create should work" do
      cu = ChangesetUser.find_or_create_by_user_id_and_changeset_id(User.current.id, @changeset.id)
      cu.save!
      @changeset.users.first.user_id.must_equal(User.current.id)
      @changeset.users.first.changeset_id.must_equal(@changeset.id)
    end

    it "changeset destroy all should work" do
      cu = ChangesetUser.find_or_create_by_user_id_and_changeset_id(User.current.id, @changeset.id)
      cu.save!
      ChangesetUser.destroy_all(:changeset_id => @changeset.id)
      @changeset.users.must_be_empty
    end

    it "changeset json should contain the types" do
      json = @changeset.as_json
      json[:action_type].wont_be_nil
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
          Changeset.with_state(Changeset::DELETED).must_be_empty
          Changeset.with_state(Changeset::NEW).size.must_equal(1)
          Changeset.with_state(Changeset::PROMOTING).size.must_equal(1)
          Changeset.with_state(Changeset::NEW, Changeset::PROMOTING).size.must_equal(2)
          Changeset.with_state(Changeset::DELETED,
                               Changeset::NEW,
                               Changeset::PROMOTING).size.must_equal(2)
        end
      end

      describe ".started" do
        subject { Changeset.started }
        it { subject.size.must_equal(2) }
        it { subject.must_include(@promoting, @deleting) }
      end

      describe ".colliding(changeset)" do
        before do
          @alpha      = katello_environments(:dev)
          @beta       = katello_environments(:staging)
          @collision = PromotionChangeset.create!(:environment => @alpha,
                                                   :name        => "collision1")
          @no_collision = PromotionChangeset.create!(:environment => @beta,
                                                   :name        => "nocollision1")
        end

        it 'should detect "identical" collision' do
          Changeset.colliding(@promoting).must_include(@deleting)
        end

        it 'should detect "following" collision' do
          Changeset.colliding(@promoting).must_include(@collision)
        end

        it 'should detect "previous" collision' do
          Changeset.colliding(@collision).must_include(@promoting)
        end

        it 'should ignore other cases' do
          Changeset.colliding(@promoting).wont_include(@no_collision) # only same start
          Changeset.colliding(@collision).wont_include(@no_collision) # nothing in common
        end
      end
    end

    describe "fail adding content not contained in the prior environment" do
      before do
        @view = FactoryGirl.create(:content_view, :organization => @organization)
        content_view = stub
        content_view.stubs(:include?).returns(false)
        prior = stub
        prior.stubs(:content_views).returns(content_view)
        environment = stub
        environment.stubs(:prior).returns(prior)
        @changeset.stubs(:environment).returns(environment)
      end

      it "should fail on add view" do
        lambda { @changeset.add_content_view!(@view) }.must_raise(Errors::ChangesetContentException)
      end
    end

    describe "promotions" do
      before(:each) do
        @changeset.stubs(:wait_for_tasks).returns(nil)
        @changeset.stubs(:affected_repos).returns([])
      end

      it "should update env content" do
        @changeset.state = Changeset::REVIEW
        @content_view_environment = @environment.content_view_environment
        @environment.stubs(:content_view_environment).returns(@content_view_environment)
        @changeset.expects(:update_view_cp_content)
        @changeset.apply(:async => false)
      end

      it "should have correct state after successful promotion" do
        @changeset.state = Changeset::REVIEW
        @changeset.apply(:async => false)
        @changeset.state.must_equal(Changeset::PROMOTED)
      end

      it "should have correct state after unsuccessful promotion" do
        @changeset.state = Changeset::REVIEW
        @changeset.stubs(:promote_views).raises(StandardError)
        lambda { @changeset.apply(:async => false) }.must_raise StandardError
        @changeset.state.must_equal(Changeset::FAILED)
      end

    end
  end

end
end
