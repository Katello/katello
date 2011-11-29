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
require 'helpers/product_test_data'
require 'helpers/repo_test_data'

include OrchestrationHelper
include ProductHelperMethods
include AuthorizationHelperMethods

describe Repository, :katello => true do

  describe "create repo"  do
    before do
      disable_org_orchestration
      suffix = rand(10**8).to_s
      @organization = Organization.create!(:name => "test_organization#{suffix}", :cp_key => "test_organization#{suffix}")
      @product = new_test_product @organization, @organization.locker
      @ep = EnvironmentProduct.find_or_create(@organization.locker, @product)
    end
    context "product has a gpg" do
      before do
        @gpg = GpgKey.create!(:name => "foo", :organization => @organization, :content=>"100")
        @product.gpg_key = @gpg
        @product.save!
      end
      subject{Repository.create!(:environment_product => @ep, :pulp_id => "pulp-id-#{rand 10**6}",
                                 :name=>"newname#{rand 10**6}", :url => "http://fedorahosted org")}
      it{should_not be_nil}
      its(:gpg_key){should == @product.gpg_key}
    end
  end

  describe "repo permission tests" do
    before (:each) do
      disable_org_orchestration
      disable_product_orchestration
      disable_user_orchestration
      suffix = rand(10**8).to_s
      @organization = Organization.create!(:name => "test_organization#{suffix}", :cp_key => "test_organization#{suffix}")

      User.current = superadmin
      @product = Product.new({:name => "prod"})
      @product.provider = @organization.redhat_provider
      @product.environments << @organization.locker
      @product.stub(:arch).and_return('noarch')
      @product.save!
      @ep = EnvironmentProduct.find_or_create(@organization.locker, @product)
      @repo = Repository.create!(:environment_product => @ep, :name => "testrepo",:pulp_id=>"1010", :enabled => true)

    end
    context "disabling a repo" do
      context "if the repo is not promoted disable operation should work" do
        before do
          @repo.stub(:promoted?).and_return(false)
          @repo.enabled = false
        end
        it "save should not raise error " do
          lambda {@repo.save!}.should_not raise_error
        end

        specify do
          @repo.save!
          Repository.find(@repo.id).enabled?.should == false
        end
      end
      context "if the repo is promoted disable operation should not work" do
        before do
          @repo.stub(:promoted?).and_return(true)
          @repo.enabled = false
        end
        it "save should raise error " do
          lambda {@repo.save!}.should raise_error(ActiveRecord::RecordInvalid)
          Repository.find(@repo.id).enabled?.should == true
        end
      end

    end
  end

end
