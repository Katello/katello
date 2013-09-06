# encoding: UTF-8

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

describe ProductsController, :katello => true do
  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods
  include AuthorizationHelperMethods
  describe "rules" do
    before do
      @organization = new_test_org
      @provider = Provider.create!(:provider_type=>Provider::CUSTOM, :name=>"foo1", :organization=>@organization)
      Provider.stub!(:find).and_return(@provider)
      @product = MemoStruct.new(:provider => @provider, :id => 1000)
    end
    describe "GET New" do
      let(:action) {:new}
      let(:req) { get :new, :provider_id => @provider.id}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :providers,@provider.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end

    describe "GET Edit" do
      before do
        Product.stub!(:find).and_return(@product)
      end
      let(:action) {:edit}
      let(:req) { get :edit, :provider_id => @provider.id, :id => @product.id}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:read, :providers,@provider.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end

    describe "post create" do
      let(:action) {:create}
      let(:req) { post :create, :provider_id => @provider.id}
      let(:authorized_user) do
        user_with_permissions { |u| u.can(:update, :providers,@provider.id, @organization) }
      end
      let(:unauthorized_user) do
        user_without_permissions
      end
      it_should_behave_like "protected action"
    end
  end

  describe "get auto_complete_product" do
    before (:each) do
      set_default_locale
      login_user
      Product.should_receive(:any_readable?).once.and_return(true)
      Product.should_receive(:search).once.and_return([OpenStruct.new(:name => "a", :id =>100)])
    end

    it 'should succeed' do
      get :auto_complete, :term => "a"
      response.should be_success
    end
  end

  describe "gpg" do
    before do
      disable_product_orchestration
      disable_org_orchestration
      disable_user_orchestration
      set_default_locale
      login_user
      @organization = new_test_org
      @provider = Provider.create!(:provider_type=>Provider::CUSTOM, :name=>"foo1", :organization=>@organization)
      Provider.stub!(:find).and_return(@provider)
      @gpg = GpgKey.create!(:name =>"GPG", :organization=>@organization, :content=>"bar")
    end
    context "when creating a product" do
      before do
        @prod_name = "booyeah"
        post :create, :provider_id => @provider.id, :product => {:name=> @prod_name, :gpg_key => @gpg.id.to_s, :label=>"boo"}
      end
      specify {response.should be_success}
      subject{Product.find_by_name(@prod_name)}
      it {should_not be_nil}
      its(:name){should == @prod_name}
      its(:gpg_key){should == @gpg}
    end

    context "when updating a product" do
      before do
        @product = Product.new({:name=>"prod", :label=> "prod"})
        @product.provider = @provider
        @product.stub(:arch).and_return('noarch')
        @product.save!
      end

      context "without repositories wizard" do
        before do
          put :update, :provider_id => @provider.id, :id => @product.id,
              :product              => { :gpg_key => @gpg.id.to_s }
        end
        specify { response.should be_success }
        subject { Product.find(@product.id) }
        its(:gpg_key) { should == @gpg }
      end

      [true, false].each do |v|
        context "with#{'out' unless v} all repositories" do
          before do
            @product.should_receive(:reset_repo_gpgs!).once.and_return([]) if v
            @product.should_not_receive(:reset_repo_gpgs!) unless v
            controller.stub(:find_product) { controller.instance_variable_set(:@product, @product) }
            put :update, :provider_id => @provider.id, :id => @product.id,
                :product              => { :gpg_key => @gpg.id.to_s, :gpg_all_repos => "#{v}" }
          end
          specify { response.should be_success }
          subject { Product.find(@product.id) }
          its(:gpg_key) { should == @gpg }
        end
      end
    end

  end
end
