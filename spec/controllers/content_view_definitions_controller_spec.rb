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

describe ContentViewDefinitionsController, :katello => true do
  include LoginHelperMethods
  include LocaleHelperMethods
  include AuthorizationHelperMethods
  include OrchestrationHelper
  include ProductHelperMethods
  include RepositoryHelperMethods

  before(:each) do
    set_default_locale
    login_user :mock=>false
    disable_org_orchestration
    disable_user_orchestration

    @organization = new_test_org
    setup_current_organization(@organization)
  end

  describe "Controller tests " do
    before(:each) do
      @definition = ContentViewDefinition.create!(:name=>'test def', :label=>'test_def',
                                                  :description=>'test description', :organization=>@organization)
    end

    describe "POST clone" do
      let(:action) {:clone}
      let(:req) {post :clone, :id => @definition.id}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:create, :content_view_definitions, @definition.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"

      it "should clone a definition correctly" do
        controller.should notify.success
        post :clone, :id => @definition.id, :name=>"foo", :description=>"describe"
        response.should be_success
        ContentViewDefinition.where(:name=>"foo", :description=>"describe").first.should_not be_nil
      end

      it "should copy products from the original definition to the clone" do
        # create a product and add it to the definition
        @product = new_test_product(@organization, @organization.library)
        @definition.products << @product
        @definition.save!

        controller.should notify.success

        post :clone, :id => @definition.id, :name=>"foo", :description=>"describe"
        response.should be_success

        clone = ContentViewDefinition.where(:name=>"foo", :description=>"describe").first
        clone.should_not be_nil
        clone.products.length.should == 1
        clone.products.first.should == @product
      end

      it "should copy repositories from the original definition to the clone" do
        # create a repo and add it to the definition
        @product = new_test_product(@organization, @organization.library)
        @ep = EnvironmentProduct.find_or_create(@organization.library, @product)
        @repo = new_test_repo(@ep, "newname#{rand 10**6}", "http://fedorahosted org")
        @definition.repositories << @repo
        @definition.save!

        controller.should notify.success

        post :clone, :id => @definition.id, :name=>"foo", :description=>"describe"
        response.should be_success

        clone = ContentViewDefinition.where(:name=>"foo", :description=>"describe").first
        clone.should_not be_nil
        clone.repositories.length.should == 1
        clone.repositories.first.should == @repo
      end

      it "should clone a definition without a description provided" do
        controller.should notify.success
        post :clone, :id => @definition.id, :name=>"foo"
        response.should be_success
        ContentViewDefinition.where(:name=>"foo").first.should_not be_nil
      end

      it "should not clone a definition without a name" do
        controller.should notify.exception
        post :clone, :id => @definition.id, :description=>"describe"
        response.should_not be_success
        ContentViewDefinition.where(:description=>"describe").first.should be_nil
      end

      it "should not allow a definition to be copied with a name that already exists" do
        controller.should notify.exception
        post :clone, :id => @definition.id, :name=>@definition.name, :description=>"describe"
        response.should_not be_success
        ContentViewDefinition.where(:name=>@definition.name).count.should == 1
      end
    end
  end

end
