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

describe Repository, :katello => true do

  include OrchestrationHelper
  include ProductHelperMethods
  include AuthorizationHelperMethods

  before do
    disable_org_orchestration
    disable_product_orchestration
    disable_user_orchestration
    suffix = rand(10**8).to_s
    @organization = Organization.create!(:name=>"test_organization#{suffix}", :label=> "test_organization#{suffix}")

    User.current = superadmin
    @product = Product.new({:name=>"prod", :label=> "prod"})
    @product.provider = @organization.redhat_provider
    @product.environments << @organization.library
    @product.stub(:arch).and_return('noarch')
    @product.save!
    @ep = EnvironmentProduct.find_or_create(@organization.library, @product)
    @repo = Repository.create!(:environment_product => @ep, :name => "testrepo", :label => "testrepo_label",
                               :pulp_id=>"1010", :enabled => true,
                               :feed => 'https://localhost')
  end


  describe "update a repo" do
    let(:gpg_key) { @organization.gpg_keys.create!(:name => "Gpg key 1", :content => "key") }
    let(:another_gpg_key) { @organization.gpg_keys.create!(:name => "Gpg key 2", :content => "another key") }
    subject do
      repo = Repository.create!(:environment_product => @ep, :pulp_id => "pulp-id-#{rand 10**6}",
                                :name=>"newname#{rand 10**6}", :label=>"newlabel#{rand 10**6}",
                                :url => "http://fedorahosted org", :gpg_key_id => gpg_key.id,
                                :feed => 'https://localhost')

      prod = repo.product
      repo.stub(:product).and_return(prod)
      repo
    end

    describe "reassigns gpg key" do
      before do
        content = OpenStruct.new(:gpgUrl=>"")
        subject.stub(:content).and_return(content)
        content.stub!(:update).and_return(content)

        content.should_not_receive(:update_content)
        subject.update_attributes!(:gpg_key_name => another_gpg_key.name)
      end

      its(:gpg_key) { should == another_gpg_key }
    end

    describe "removing gpg key assigment" do
      before do
        content = OpenStruct.new(:gpgUrl=>"http://foo")
        subject.stub(:content).and_return(content)
        content.stub!(:update).and_return(content)
        subject.update_attributes!(:gpg_key_name => nil)
      end

      its(:gpg_key) { should == nil }
    end
  end



  describe "repo permission tests" do

    context "Repo readables" do
      before do
        @repo.stub(:promoted?).and_return(false)
      end
      specify "user with content perms on env can access " do
        User.current = user_with_permissions{|u|
          u.can([:read_contents], :environments, @organization.library.id, @organization)}
        Repository.readable(@organization.library).should == [@repo]
      end
      specify "user without content perms on env cannot access " do
        User.current = user_without_permissions
        Repository.readable(@organization.library).should == []
      end


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
