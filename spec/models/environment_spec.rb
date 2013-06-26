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
describe KTEnvironment do
  include AuthorizationHelperMethods
  include OrchestrationHelper

  describe "perm tests" do
    before do
      disable_product_orchestration
      disable_org_orchestration
      @organization = Organization.create!(:name=>'test_organization', :label=> 'test_organization')
      @env_name =  'test_environment'
      @environment = KTEnvironment.create!({:name=>@env_name, :label=> @env_name, :organization => @organization, :prior => @organization.library})
    end
    describe "check on operations" do

      all_verb_methods = [:viewable_for_promotions?,
                          :any_operation_readable?,
                          :changesets_promotable?,
                          :changesets_readable?,
                          :changesets_manageable?,
                          :contents_readable?,
                          :systems_readable?,
                          :systems_editable?,
                          :systems_deletable?,
                          :systems_registerable?]

      permission_matrix = {
          :read_contents =>  [:any_operation_readable?, :contents_readable?, :viewable_for_promotions?],
          :read_systems => [:any_operation_readable?, :systems_readable?],
          :register_systems => [:any_operation_readable?, :systems_readable?,:systems_registerable?],
          :update_systems => [:any_operation_readable?, :systems_readable?, :systems_editable? ],
          :delete_systems => [:any_operation_readable?, :systems_readable?, :systems_deletable? ],
          :read_changesets => [:any_operation_readable?, :changesets_readable?, :viewable_for_promotions?],
          :manage_changesets => [:any_operation_readable?, :changesets_readable?, :changesets_manageable?, :viewable_for_promotions? ],
          :promote_changesets => [:any_operation_readable?, :changesets_readable?, :changesets_promotable?, :viewable_for_promotions?],
      }
      permission_matrix.each_pair do |perm, true_ops|
        true_ops.each do |op|
          it "user with #{perm} on environments should be allowed to #{op}", :katello => true do #TODO headpin
            User.current = user_with_permissions{|u| u.can(perm, :environments,nil, @organization, :all_tags => true)}
            KTEnvironment.find(@environment.id).send(op).should be_true
          end
          it "user without perms should not  be allowed" do
            User.current = user_without_permissions
            KTEnvironment.find(@environment.id).send(op).should_not be_true
          end
        end
        false_ops = all_verb_methods - true_ops
        false_ops.each do |op|
          it "user with #{perm} on environments should NOT be allowed to #{op}" do
            User.current = user_with_permissions{|u| u.can(perm, :environments,nil, @organization, :all_tags => true)}
            KTEnvironment.find(@environment.id).send(op).should_not be_true
          end
          it "user without perms should not  be allowed" do
            User.current = user_without_permissions
            KTEnvironment.find(@environment.id).send(op).should_not be_true
          end

        end
      end
    end
  end

  describe "main" do
    before(:each) do

      disable_product_orchestration
      disable_repo_orchestration
      disable_org_orchestration
      Repository.any_instance.stub(:save_content_orchestration).and_return(true)
      Repository.any_instance.stub(:clear_content_indices).and_return(true)
      Repository.any_instance.stub(:destroy_repo_orchestration).and_return(true)

      @env_name =  'test_environment'

      @organization = Organization.create!(:name=>'test_organization', :label=> 'test_organization')
      @provider = @organization.redhat_provider

      @first_product = Product.create!(:name =>"prod1", :label=>"prod1", :cp_id => '12345', :provider => @provider)
      @second_product = Product.create!(:name =>"prod2", :label=> "prod2", :cp_id => '67890', :provider => @provider)
      @third_product = Product.create!(:name =>"prod3", :label=> "prrod3",:cp_id => '45678', :provider => @provider)
      @fourth_product = Product.create!(:name =>"prod4", :label => "prod4", :cp_id => '32683', :provider => @provider)

      @environment = KTEnvironment.new({:name=>@env_name, :label=> @env_name, :prior => @organization.library})
      @organization.environments << @environment
      @organization.save!
      @environment.save!
      FactoryGirl.create(:repository, product: @first_product, environment: @environment, content_view_version_id: 1)
      FactoryGirl.create(:repository, product: @third_product, environment: @environment, content_view_version_id: 1)
    end

    specify { @environment.name.should == @env_name }
    #specify { @environment.prior.should be_nil }
    specify { @environment.successor.should be_nil }
    specify { @organization.environments.should include @environment }
    specify { @environment.organization.should == @organization }
    specify { @environment.products.size.should == 2 }
    specify { @environment.products.should include @first_product }
    specify { @environment.products.should include @third_product }

    context "prior environment can be set" do
      before { @new_env = KTEnvironment.create!({:name=>@environment.name + '-prior', :label=> @environment.name + '-prior',
          :prior => @environment.id,
          :organization => @organization
      })}

      specify { @new_env.prior.should == @environment }
      specify { @environment.successor.should == @new_env }
    end

    describe "update an environment" do
      specify "name should not be changed" do
        @environment.name = "changed_name"
        @environment.should be_valid
      end
    end

    context "delete an environment" do

      it "should delete the environment" do
        id = @environment.id
        @environment.destroy
        lambda{KTEnvironment.find(id)}.should raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "available products" do

      before(:each) do
        @prior_env = KTEnvironment.new({:name=>@env_name + '-prior', :label=> @env_name + '-prior', :prior => @environment.id})
        @organization.environments << @prior_env
        @prior_env.save!
        @organization.save!

        FactoryGirl.create(:repository, environment: @prior_env, product: @first_product, content_view_version_id: 1)
        FactoryGirl.create(:repository, environment: @prior_env, product: @second_product, content_view_version_id: 1)
        FactoryGirl.create(:repository, environment: @prior_env, product: @third_product, content_view_version_id: 1)

        FactoryGirl.create(:repository, environment: @organization.library, product: @first_product, content_view_version_id: 1)
        FactoryGirl.create(:repository, environment: @organization.library, product: @second_product, content_view_version_id: 1)
        FactoryGirl.create(:repository, environment: @organization.library, product: @third_product, content_view_version_id: 1)
        FactoryGirl.create(:repository, environment: @organization.library, product: @fourth_product, content_view_version_id: 1)
      end

      it "should return products from prior env" do
        @environment.prior = @prior_env.id

        @environment.available_products.size.should == 1
        @environment.available_products.should include @second_product
      end

      it "should return products from the library if there is no prior env" do
        @environment.available_products.size.should == 2
        @environment.available_products.should include @second_product
        @environment.available_products.should include @fourth_product
      end

    end

    context "create environment with invalid parameters" do
      it "should be invalid to create two envs with the same name within one organization" do
        @environment2 = KTEnvironment.new({:name => @env_name})
        @organization.environments << @environment2

        @environment2.should_not be_valid
        @environment2.errors[:name].should_not be_empty
      end

      it "should be invalid to create an environment without a prior" do
        @environment2 = KTEnvironment.new({:name => @env_name})
        @organization.environments << @environment2

        @environment2.should_not be_valid
        @environment2.errors[:prior].should_not be_empty
      end
    end

    context "environment path" do
      before(:each) do
        @env1 = KTEnvironment.new({:name => @env_name + '-succ1', :label=>'env-succ1'})
        @env2 = KTEnvironment.new({:name => @env_name + '-succ2',:label=>'env-succ2'})
        @organization.environments << @env1
        @organization.environments << @env2
        @env1.prior = @environment.id
        @env1.save!
        @env2.prior = @env1.id
        @env2.save!
      end

      specify { @environment.path.size.should == 3 }
      specify { @environment.path.should include @env1 }
      specify { @environment.path.should include @env2 }
    end

    context "Test priors" do
      before(:each) do
        @e1 = KTEnvironment.create!({:name=>@env_name + '-succ1', :label=> @env_name + '-succ1',
                  :organization => @organization, :prior => @environment})
        @e2 = KTEnvironment.create!({:name=>@env_name + '-succ2', :label=> @env_name + '-succ2',
                  :organization => @organization, :prior => @e1})

        @organization.environments << @e1
        @organization.environments << @e2
      end

      specify{ lambda {KTEnvironment.create!({:name=>@env_name + '-succ3', :label=> @env_name + '-succ3',
                :organization => @organization, :prior => @e1})}.should raise_error(ActiveRecord::RecordInvalid)}

    end

    context "libraries" do
      it "should be the only KTEnvironment that can have multiple priors" do
        @env1 = KTEnvironment.new({:name=>@env_name + '1', :label=> @env_name + '1',
                  :organization => @organization, :prior => @organization.library})
        @env2 = KTEnvironment.new({:name=>@env_name + '2', :label=> @env_name + '2',
                  :organization => @organization, :prior => @organization.library})
        @env3 = KTEnvironment.new({:name=>@env_name + '3', :label=> @env_name + '3',
                  :organization => @organization, :prior => @organization.library})

        @env1.should be_valid
        @env2.should be_valid
        @env3.should be_valid
        @organization.library.should be_valid
      end
    end

    describe "updating CP content assignment" do
      it "should add content not already promoted" do
        @content_view_environment = @environment.content_view_environment
        already_promoted_content("123", "456")
        newly_promoted_content("123", "456", "789", "10")
        Resources::Candlepin::Environment.should_receive(:add_content).with(@environment.id.to_s, Set.new(["789", "10"]))
        @content_view_environment.update_cp_content
      end

      def already_promoted_content(*content_ids)
        @already_promoted_content_ids = content_ids
        Resources::Candlepin::Environment.stub(:find).and_return(
          {:environmentContent => @already_promoted_content_ids.map {|id| {:contentId => id}}})
      end

      def newly_promoted_content(*content_ids)
        promoted_repos = content_ids.map{|id| mock(:content_id => id, :enabled=>true) }
        @content_view_environment.stub_chain(:content_view, :repos).and_return(promoted_repos)
      end
    end
  end
end
