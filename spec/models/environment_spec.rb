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

describe KTEnvironment do

  before(:each) do

    disable_product_orchestration
    disable_org_orchestration
    
    @env_name =  'test_environment'
    
    @organization = Organization.create!(:name => 'test_organization', :cp_key => 'test_organization')
    @provider = @organization.redhat_provider

    @first_product = Product.new(:name =>"prod1", :cp_id => '12345', :provider => @provider, :environments => [@organization.library])
    @second_product = Product.new(:name =>"prod2", :cp_id => '67890', :provider => @provider, :environments => [@organization.library])
    @third_product = Product.new(:name =>"prod3", :cp_id => '45678', :provider => @provider, :environments => [@organization.library])
    @fourth_product = Product.new(:name =>"prod4", :cp_id => '32683', :provider => @provider, :environments => [@organization.library])

    @environment = KTEnvironment.new({:name => @env_name, :prior => @organization.library}) do |e|
      e.products << @first_product
      e.products << @third_product
    end
    @organization.environments << @environment
    @organization.save!
    @environment.save!

    @first_product.save!
    @second_product.save!
    @third_product.save!
    @fourth_product.save!
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
    before { @new_env = KTEnvironment.create!({
        :name => @environment.name + '-prior',
        :prior => @environment.id,
        :organization => @organization
    })}

    specify { @new_env.prior.should == @environment }
    specify { @environment.successor.should == @new_env }
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
      @prior_env = KTEnvironment.new({:name => @env_name + '-prior', :prior => @environment.id}) do |e|
        e.products << @first_product
        e.products << @second_product
        e.products << @third_product
      end
      @organization.environments << @prior_env
      @prior_env.save!
      @organization.save!
      
      @organization.library.products << @first_product
      @organization.library.products << @second_product
      @organization.library.products << @third_product
      @organization.library.products << @fourth_product
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
      @env1 = KTEnvironment.new({:name => @env_name + '-succ1'})
      @env2 = KTEnvironment.new({:name => @env_name + '-succ2'})
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
      @e1 = KTEnvironment.create!({:name => @env_name + '-succ1',
                :organization => @organization, :prior => @environment})
      @e2 = KTEnvironment.create!({:name => @env_name + '-succ2',
                :organization => @organization, :prior => @e1})
      
      @organization.environments << @e1
      @organization.environments << @e2
    end
    
    specify{ lambda {KTEnvironment.create!({:name => @env_name + '-succ3',
              :organization => @organization, :prior => @e1})}.should raise_error(ActiveRecord::RecordInvalid)}
              
  end
  
  context "libraries" do
    it "should be the only KTEnvironment that can have multiple priors" do
      @env1 = KTEnvironment.new({:name => @env_name + '1',
                :organization => @organization, :prior => @organization.library})
      @env2 = KTEnvironment.new({:name => @env_name + '2',
                :organization => @organization, :prior => @organization.library})
      @env3 = KTEnvironment.new({:name => @env_name + '3',
                :organization => @organization, :prior => @organization.library})
                
      @env1.should be_valid
      @env2.should be_valid
      @env3.should be_valid
      @organization.library.should be_valid
    end
  end

  describe "updating CP content assignment" do
    it "should add content not already promoted" do
      already_promoted_content("123", "456")
      newly_promoted_content("123", "456", "789", "10")
      Candlepin::Environment.should_receive(:add_content).with(@environment.id, Set.new(["789", "10"]))
      @environment.update_cp_content
    end

    def already_promoted_content(*content_ids)
      @already_promoted_content_ids = content_ids
      Candlepin::Environment.stub(:find).and_return(
        {:environmentContent => @already_promoted_content_ids.map {|id| {:contentId => id}}})
    end

    def newly_promoted_content(*content_ids)
      promoted_repos = content_ids.map{|id| mock(:content_id => id) }
      @environment.stub_chain(:repositories, :enabled).and_return(promoted_repos)
    end
  end
end






















