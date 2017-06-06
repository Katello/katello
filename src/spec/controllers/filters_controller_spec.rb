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

describe FiltersController, :katello => true do
  include LoginHelperMethods
  include LocaleHelperMethods
  include AuthorizationHelperMethods
  include OrchestrationHelper

  before(:each) do
    set_default_locale
    login_user :mock=>false
    disable_org_orchestration
    disable_user_orchestration

    @organization = new_test_org
    setup_current_organization(@organization)
  end

  describe "Controller permission tests" do
    before(:each) do
      @definition = ContentViewDefinition.create!(:name=>'test def', :label=>'test_def',
                                                  :description=>'test description', :organization=>@organization)

      @filter = mock_model(Filter, {:id => 1, :content_view_definition => @definition})
      Filter.stub(:find).and_return(@filter)
    end

    describe "GET index" do
      let(:action) { :index }
      let(:req) { get :index, :content_view_definition_id => @definition.id }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :content_view_definitions, @definition.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end

    describe "GET new" do
      let(:action) { :new }
      let(:req) { get :new, :content_view_definition_id => @definition.id }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :content_view_definitions, @definition.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end

    describe "POST create" do
      let(:action) { :create }
      let(:req) { post :create, :content_view_definition_id => @definition.id }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :content_view_definitions, @definition.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end

    describe "GET edit" do
      let(:action) { :edit }
      let(:req) { get :edit, :content_view_definition_id => @definition.id, :id => @filter.id }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :content_view_definitions, @definition.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end

    describe "PUT update" do
      let(:action) { :update }
      let(:req) { put :update, :content_view_definition_id => @definition.id, :id => @filter.id }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :content_view_definitions, @definition.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end

    describe "DELETE destroy_filters" do
      let(:action) { :destroy_filters }
      let(:req) { delete :destroy_filters, :content_view_definition_id => @definition.id }
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :content_view_definitions, @definition.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end

  end

end
