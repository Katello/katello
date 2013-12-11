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

require 'katello_test_helper'
#require 'ostruct'

module Katello
  describe ProductsController do

    include LocaleHelperMethods
    include OrganizationHelperMethods
    include AuthorizationHelperMethods

    describe "(katello)" do

      before do
        setup_controller_defaults
        @organization = new_test_org
      end

      describe "rules" do
        before do
          @provider = Provider.create!(:provider_type=>Provider::CUSTOM, :name=>"foo1", :organization=>@organization)
          Provider.stubs(:find).returns(@provider)
          @product = OpenStruct.new(:provider => @provider, :id => 1000)
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
            Product.stubs(:find).returns(@product)
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
          Product.expects(:any_readable?).once.returns(true)
          Product.expects(:search).once.returns([OpenStruct.new(:name => "a", :id =>100)])
        end

        it 'should succeed' do
          get :auto_complete, :term => "a"
          must_respond_with(:success)
        end
      end

      describe "gpg" do
        before do
          disable_product_orchestration
          disable_org_orchestration
          disable_user_orchestration
          set_default_locale
          @provider = Provider.create!(:provider_type=>Provider::CUSTOM, :name=>"foo1", :organization=>@organization)
          Provider.stubs(:find).returns(@provider)
          test_gpg_content = File.open("#{Katello::Engine.root}/spec/assets/gpg_test_key").read
          @gpg = GpgKey.create!(:name =>"GPG", :organization=>@organization, :content=>test_gpg_content)
        end
        describe "when creating a product" do
          before do
            @prod_name = "booyeah"
            post :create, :provider_id => @provider.id, :product => {:name=> @prod_name, :gpg_key => @gpg.id.to_s, :label=>"boo"}
          end
          specify {must_respond_with(:success)}
          subject{Product.find_by_name(@prod_name)}
          it {wont_be_nil}
          it { subject.name.must_equal @prod_name }
          it { subject.gpg_key.must_equal @gpg }
        end

        describe "when updating a product" do
          before do
            @product = Product.new({:name=>"prod", :label=> "prod"})
            @product.provider = @provider
            @product.stubs(:arch).returns('noarch')
            @product.save!
          end

          describe "without repositories wizard" do
            before do
              put :update, :provider_id => @provider.id, :id => @product.id,
                :product              => { :gpg_key => @gpg.id.to_s }
            end
            specify { must_respond_with(:success) }
            subject { Product.find(@product.id) }
            it { subject.gpg_key.must_equal @gpg }
          end

          describe "with all repositories" do
            before do
              @product.expects(:reset_repo_gpgs!)
              Product.stubs(:find).returns(@product)
              put :update, :provider_id => @provider.id, :id => @product.id,
                :product              => { :gpg_key => @gpg.id.to_s, :gpg_all_repos => "true" }
            end
            specify { must_respond_with(:success) }
            subject { Product.find(@product.id) }
            it { subject.gpg_key.must_equal @gpg }
          end

          describe "without all repositories" do
            before do
              @product.expects(:reset_repo_gpgs!).never
              put :update, :provider_id => @provider.id, :id => @product.id,
                :product              => { :gpg_key => @gpg.id.to_s, :gpg_all_repos => "false" }
            end
            specify { must_respond_with(:success) }
            subject { Product.find(@product.id) }
            it { subject.gpg_key.must_equal @gpg }
          end
        end

      end
    end

  end
end
