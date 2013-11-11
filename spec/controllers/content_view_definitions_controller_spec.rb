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
describe ContentViewDefinitionsController do

  include LocaleHelperMethods
  include AuthorizationHelperMethods
  include OrchestrationHelper
  include ProductHelperMethods
  include RepositoryHelperMethods

  before(:each) do
    setup_controller_defaults
    disable_org_orchestration
    disable_user_orchestration

    @organization = katello_organizations(:acme_corporation)
    @controller.stubs(:current_organization).returns(@organization)
  end

  describe "Controller tests (katello)" do
    before(:each) do
      @definition = ContentViewDefinition.create!(:name=>'test def', :label=>'test_def',
                                                  :description=>'test description', :organization=>@organization)
    end

    describe "GET items" do
      let(:action) { :items }
      let(:req) { get :items }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :content_view_definitions, @definition.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "requests items using search criteria" do
        @controller.expects(:render_panel_direct)
        @controller.stubs(:render).returns('')
        get :items
        must_respond_with(:success)
      end
    end

    describe "GET show" do
      let(:action) { :show }
      let(:req) { get :show, :id => @definition.id }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :content_view_definitions, @definition.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "should render the list update partial" do
        get :show, :id => @definition.id
        must_respond_with(:success)
        must_render_template(:partial => "katello/common/_list_update")
      end
    end

    describe "GET new" do
      let(:action) { :new }
      let(:req) { get :new }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:create, :content_view_definitions, nil, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "should render the new partial" do
        get :new
        must_respond_with(:success)
        must_render_template(:partial => "_new")
      end
    end

    describe "POST create" do
      before(:each) do
        @controller.stubs(:search_validate).returns(true)
      end

      let(:action) { :create }
      let(:req) { post :create }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:create, :content_view_definitions, nil, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "should create a non-composite definition correctly" do
        must_notify_with(:success)
        post :create, :content_view_definition=>{:name=>"foo", :description=>"describe"}
        must_respond_with(:success)
        definition = ContentViewDefinition.where(:name=>"foo").first
        definition.wont_be_nil
        definition.component_content_views.length.must_equal 0
      end

      it "should create a composite definition correctly" do
        @component_content_view = FactoryGirl.create(:content_view)

        must_notify_with(:success)
        post :create, :content_view_definition=>{:name=>"foo", :composite=>true}, :content_views => {@component_content_view.id => "1"}
        must_respond_with(:success)
        definition = ContentViewDefinition.where(:name=>"foo").first
        definition.wont_be_nil
        definition.component_content_views.length.must_equal 1
      end
    end

    describe "GET edit" do
      let(:action) { :edit }
      let(:req) { get :edit, :id=>@definition.id }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :content_view_definitions, @definition.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "should render the edit partial" do
        get :edit, :id=>@definition.id
        must_respond_with(:success)
        must_render_template(:partial => "_edit")
      end
    end

    describe "POST update" do
      before(:each) do
        @controller.stubs(:search_validate).returns(true)
      end

      let(:action) { :update }
      let(:req) { post :update, :id=>@definition.id }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :content_view_definitions, @definition.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "should allow name to be changed" do
        old_name = @definition.name
        old_label = @definition.label

        must_notify_with(:success)
        put :update, :id=>@definition.id, :view_definition=>{:name=>"this is my new name"}

        must_respond_with(:success)

        definition = ContentViewDefinition.where(:name=>'this is my new name').first
        definition.wont_be_nil
        definition.label.must_equal old_label # changing the name should not affect the label

        ContentViewDefinition.where(:name=>old_name).first.must_be_nil
      end

      it "should allow the description to be changed" do
        old_description = @definition.description

        must_notify_with(:success)
        put :update, :id=>@definition.id, :view_definition=>{:description=>"this is my new description"}

        must_respond_with(:success)
        ContentViewDefinition.where(:description=>'this is my new description').first.wont_be_nil
        ContentViewDefinition.where(:description=>old_description).first.must_be_nil
      end

      it "should not allow the label to be changed" do
        old_label = @definition.label

        put :update, :id=>@definition.id, :view_definition=>{:label=>"this is my new label"}

        response.must_respond_with(422)
        ContentViewDefinition.where(:label=>old_label).first.wont_be_nil
      end
    end

    describe "POST destroy" do
      let(:action) { :destroy }
      let(:req) { delete :destroy, :id=>@definition.id}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:delete, :content_view_definitions, @definition.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "should complete successfully" do
        @controller.stubs(:render).returns("") #ignore missing list_remove js partial
        must_notify_with(:success)
        delete :destroy, :id=>@definition.id

        must_respond_with(:success)
        ContentViewDefinition.where(:name=>@definition.name).first.must_be_nil
      end
    end

    describe "GET publish_setup" do
      let(:action) { :publish_setup }
      let(:req) { get :publish_setup, :id=>@definition.id }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:publish, :content_view_definitions, @definition.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "should complete successfully" do
        get :publish_setup, :id=>@definition.id
        must_respond_with(:success)
        must_render_template(:partial => "_publish")
      end
    end

    describe "POST publish" do
      let(:action) { :publish }
      let(:req) { get :publish, :id=>@definition.id }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:publish, :content_view_definitions, @definition.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "should complete successfully" do
        ContentViewDefinition.stubs(:find).returns(@definition)
        @definition.expects(:publish)

        must_notify_with(:success)
        post :publish, :id=>@definition.id, :content_view => {:name => "published_view"}
        must_respond_with(:success)
      end

      it "should fail if content view not provided" do
        post :publish, :id=>@definition.id
        must_respond_with(400)
      end

      it "should not publish a content view definition with puppet name conflicts" do
        ContentViewDefinition.stub(:find).and_return(@definition)
        @definition.stub_chain(:puppet_repository, :name_conflicts).and_return([:apache])
        controller.should notify.error

        post :publish, :id => @definition.id, :content_view => {:name => "published_view"}
        response.should_not be_success
      end
    end

    describe "GET content" do
      let(:action) { :content }
      let(:req) { get :content, :id=>@definition.id }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :content_view_definitions, @definition.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "should be successful, for non-composite definition" do
        get :content, :id=>@definition.id
        must_respond_with(:success)
        must_render_template(:partial => "_single_definition_content")
      end

      it "should be successful, for composite definition" do
        @definition.composite = true
        @definition.save!

        get :content, :id=>@definition.id
        must_respond_with(:success)
        must_render_template(:partial => "_composite_definition_content")
      end
    end

    describe "POST update_content" do
      let(:action) { :update_content }
      let(:req) { post :update_content, :id=>@definition.id }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :content_view_definitions, @definition.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      before(:each) do
        @product = new_test_product(@organization, @organization.library)
      end

      it "should successfully update products" do
        assert @definition.products.size == 0

        must_notify_with(:success)
        post :update_content, :id=>@definition.id, :products=>[@product.id]

        must_respond_with(:success)
        ContentViewDefinition.where(:id=>@definition.id).first.products.first.must_equal @product
      end

      it "should unset products if products param is nil" do
        @definition.products = [@product]
        @definition.save!
        @definition.products.reload.length.must_equal(1)

        post :update_content, :id=>@definition.id
        must_respond_with(:success)
        @definition.products.reload.length.must_equal(1)

        post :update_content, :id=>@definition.id, :products => nil
        must_respond_with(:success)
        @definition.products.reload.length.must_equal(0)
      end

      it "should successfully update repositories" do
        assert @definition.repositories.size == 0

        must_notify_with(:success)
        post :update_content, :id=>@definition.id,
             :repos=>{@product.id => [@product.repos(@organization.library).first.id]}

        must_respond_with(:success)
        ContentViewDefinition.where(:id=>@definition.id).first.repositories.first.must_equal(
                                    @product.repos(@organization.library).first)
      end

      it "should successfully update the puppet repository" do
        assert @definition.repositories.size == 0
        Repository.any_instance.stubs(:create_pulp_repo).returns([])
        repo = create(:repository, :puppet, :product => @product,
                      :environment => @organization.library,
                      :content_view_version => @organization.library.default_content_view_version)

        post :update_content, :id=>@definition.id, :puppet_repository_id => repo.id

        must_respond_with(:success)
        @definition.repositories.reload.must_equal([repo])
        @definition.puppet_repository.must_equal(repo)

        post :update_content, :id=>@definition.id, :puppet_repository_id => ""

        must_respond_with(:success)
        @definition.repositories.reload.length.must_equal(0)
      end
    end

    describe "GET views" do
      let(:action) { :views }
      let(:req) { post :views, :id=>@definition.id }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :content_view_definitions, @definition.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "should be successful" do
        get :views, :id=>@definition.id
        must_respond_with(:success)
      end
    end

    describe "POST clone" do
      let(:action) {:clone}
      let(:req) {post :clone, :id => @definition.id}
      let(:authorized_user) do
        user_with_permissions do |u|
          u.can(:read, :content_view_definitions, @definition.id, @organization)
          u.can(:create, :content_view_definitions, nil, @organization)
        end
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "should clone a definition correctly" do
        must_notify_with(:success)
        post :clone, :id => @definition.id, :name=>"foo", :description=>"describe"
        must_respond_with(:success)
        ContentViewDefinition.where(:name=>"foo", :description=>"describe").first.wont_be_nil
      end

      it "should copy products from the original definition to the clone" do
        # create a product and add it to the definition
        @product = new_test_product(@organization, @organization.library)
        @definition.products << @product
        @definition.save!

        must_notify_with(:success)

        post :clone, :id => @definition.id, :name=>"foo", :description=>"describe"
        must_respond_with(:success)

        clone = ContentViewDefinition.where(:name=>"foo", :description=>"describe").first
        clone.wont_be_nil
        clone.products.length.must_equal 1
        clone.products.first.must_equal @product
      end

      it "should copy repositories from the original definition to the clone" do
        # create a repo and add it to the definition
        @product = new_test_product(@organization, @organization.library)
        @repo = new_test_repo(@organization.library, @product, "newname#{rand 10**6}", "http://fedorahosted org")
        @definition.repositories << @repo
        @definition.save!

        must_notify_with(:success)

        post :clone, :id => @definition.id, :name=>"foo", :description=>"describe"
        must_respond_with(:success)

        clone = ContentViewDefinition.where(:name=>"foo", :description=>"describe").first
        clone.wont_be_nil
        clone.repositories.length.must_equal 1
        clone.repositories.first.must_equal @repo
      end

      it "should clone a definition without a description provided" do
        must_notify_with(:success)
        post :clone, :id => @definition.id, :name=>"foo"
        must_respond_with(:success)
        ContentViewDefinition.where(:name=>"foo").first.wont_be_nil
      end

      it "should not clone a definition without a name" do
        must_notify_with(:exception)
        post :clone, :id => @definition.id, :description=>"describe"
        response.must_respond_with(422)
        ContentViewDefinition.where(:description=>"describe").first.must_be_nil
      end

      it "should not allow a definition to be copied with a name that already exists" do
        must_notify_with(:exception)
        post :clone, :id => @definition.id, :name=>@definition.name, :description=>"describe"
        response.must_respond_with(422)
        ContentViewDefinition.where(:name=>@definition.name).count.must_equal 1
      end
    end
  end

end
end
