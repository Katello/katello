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

describe ContentViewsController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods
  include AuthorizationHelperMethods

  before (:each) do
    set_default_locale
    login_user
    @organization = new_test_org

    @definition = ContentViewDefinition.create!(:name => 'test def', :label => 'test_def',
                                                :description => 'test description',
                                                :organization => @organization)

    @view = ContentView.create!(:name => 'test view', :label => 'test_view',
                                :organization => @organization,
                                :content_view_definition => @definition)
  end

  describe "GET auto_complete rules" do

    let(:action) { :auto_complete }
    let(:req) { get :auto_complete, :term => "a" }
    let(:authorized_user) do
      user_with_permissions { |u| u.can(:read, :content_views, nil, @organization) }
    end
    let(:unauthorized_user) do
      user_without_permissions
    end
    it_should_behave_like "protected action"
  end

  describe "GET auto_complete" do
    before (:each) do
      ContentView.should_receive(:search).once.and_return([OpenStruct.new(:name => "a", :id =>100)])
    end

    it 'should succeed' do
      get :auto_complete, :term => "a"
      response.should be_success
    end
  end

  describe "POST refresh" do
    let(:action) { :refresh }
    let(:req) { post :refresh, :content_view_definition_id => @definition.id, :id => @view.id }
    let(:authorized_user) do
      user_with_permissions { |u| u.can(:publish, :content_view_definitions, @definition.id, @organization) }
    end
    let(:unauthorized_user) do
      user_without_permissions
    end
    it_should_behave_like "protected action"
  end

  describe "DELETE destroy" do
    let(:action) { :destroy }
    let(:req) { delete :destroy, :content_view_definition_id => @definition.id, :id => @view.id }
    let(:authorized_user) do
      user_with_permissions { |u| u.can(:publish, :content_view_definitions, @definition.id, @organization) }
    end
    let(:unauthorized_user) do
      user_without_permissions
    end
    it_should_behave_like "protected action"
  end

end
