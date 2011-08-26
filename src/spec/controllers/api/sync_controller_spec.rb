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
include OrchestrationHelper

describe Api::SyncController do
  include LoginHelperMethods
  include LocaleHelperMethods

  let(:provider_id) { "123" }
  let(:product_id) { "123" }
  let(:repository_id) { "123" }
  let(:async_task_1) do
    { :id => "123",
      :state => "waiting",
      :start_time => DateTime.new,
      :finish_time => DateTime.new,
      :progress => nil }
  end
  let(:async_task_2) do
    { :id => "456",
      :state => "waiting",
      :start_time => DateTime.new,
      :finish_time => DateTime.new,
      :progress => nil }
  end

  before(:each) do
    login_user
    set_default_locale
    disable_org_orchestration
  end

  describe "find_object" do
    it "should find provider if :provider_id is specified" do
      found_provider = {}
      Provider.should_receive(:find).once.with(provider_id).and_return(found_provider)
      controller.stub!(:params).and_return({:provider_id => provider_id })

      controller.find_object.should == found_provider
    end

    it "should find product if :product_id is specified" do
      found_product = {}
      Product.should_receive(:find_by_cp_id).once.with(product_id).and_return(found_product)
      controller.stub!(:params).and_return({:product_id => product_id })

      controller.find_object.should == found_product
    end

    it "should find repository if :repository_id is specified" do
      found_repository = Glue::Pulp::Repo.new
      found_repository.stub!(:environment).and_return(KTEnvironment.new(:locker => true))

      Glue::Pulp::Repo.should_receive(:find).once.with(repository_id).and_return(found_repository)
      controller.stub!(:params).and_return({:repository_id => repository_id })

      controller.find_object.should == found_repository
    end

    it "should raise an error if none were specified" do
      lambda { controller.find_object }.should raise_error(HttpErrors::NotFound)
    end
  end

  describe "start a sync" do
    before(:each) do
      @organization = Organization.create!(:name => "organization", :cp_key => "123")

      @syncable = mock()
      @syncable.stub!(:sync).and_return([async_task_1, async_task_2])
      @syncable.stub!(:organization).and_return(@organization)

      Provider.stub!(:find).and_return(@syncable)
    end

    it "should find provider" do
      Provider.should_receive(:find).once.with(provider_id).and_return(@syncable)
      post :create, :provider_id => provider_id
    end

    it "should call sync on the object of synchronization" do
       @syncable.should_receive(:sync).once.and_return([async_task_1, async_task_2])
       post :create, :provider_id => provider_id
    end

    it "should persist all sync objects" do
      post :create, :provider_id => provider_id

      found = PulpTaskStatus.all
      found.size.should == 2
      found.any? {|t| t[:uuid] == async_task_1[:id]} .should == true
      found.any? {|t| t[:uuid] == async_task_2[:id]} .should == true
    end

    it "should return sync objects" do
      post :create, :provider_id => provider_id

      status = JSON.parse(response.body)
      status.size.should == 2
      status.any? {|s| s['uuid'] == async_task_1[:id]} .should == true
      status.any? {|s| s['uuid'] == async_task_2[:id]} .should == true
    end
  end
end