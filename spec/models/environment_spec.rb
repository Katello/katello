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

describe KPEnvironment do

  before(:each) do

    disable_product_orchestration
    disable_org_orchestretion
    
    @env_name =  'test_environment'
    
    @organization = Organization.create!(:name => 'test_organization', :cp_key => 'test_organization')
    @provider = Provider.new({
      :name => 'test_provider',
      :repository_url => 'https://something',
      :provider_type => Provider::REDHAT,
      :organization => @organization
    })

    @first_product = Product.new(:name =>"prod1", :cp_id => '12345', :provider => @provider, :environments => [@organization.locker])
    @second_product = Product.new(:name =>"prod2", :cp_id => '67890', :provider => @provider, :environments => [@organization.locker])
    @third_product = Product.new(:name =>"prod3", :cp_id => '45678', :provider => @provider, :environments => [@organization.locker])
    @fourth_product = Product.new(:name =>"prod4", :cp_id => '32683', :provider => @provider, :environments => [@organization.locker])

    @environment = KPEnvironment.new({:name => @env_name, :prior => 1}) do |e|
      e.products << @first_product
      e.products << @third_product
    end
    @organization.environments << @environment
    @organization.save!
    @environment.save!

    @first_product.save!
    @second_product.save!
    @third_product.save!
    
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
    before { @new_env = KPEnvironment.create!({
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
      lambda{KPEnvironment.find(id)}.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "available products" do
    
    before(:each) do
      @prior_env = KPEnvironment.new({:name => @env_name + '-prior', :prior => @environment.id}) do |e|
        e.products << @first_product
        e.products << @second_product
        e.products << @third_product
      end
      @organization.environments << @prior_env
      @prior_env.save!
      @organization.save!
      
      @organization.locker.products << @first_product
      @organization.locker.products << @second_product
      @organization.locker.products << @third_product
      @organization.locker.products << @fourth_product
    end
    
    it "should return products from prior env" do
      @environment.prior = @prior_env.id
      
      @environment.available_products.size.should == 1
      @environment.available_products.should include @second_product
    end
    
    it "should return products from the locker if there is no prior env" do
      @environment.available_products.size.should == 2
      @environment.available_products.should include @second_product
      @environment.available_products.should include @fourth_product
    end

  end
  
  context "create environment with invalid parameters" do
    it "should be invalid to create two envs with the same name within one organization" do
      @environment2 = KPEnvironment.new({:name => @env_name})
      @organization.environments << @environment2
    
      @environment2.should_not be_valid
      @environment2.errors[:name].should_not be_empty
    end
  end
  
  context "environment path" do
    before(:each) do
      @env1 = KPEnvironment.new({:name => @env_name + '-succ1'})
      @env2 = KPEnvironment.new({:name => @env_name + '-succ2'})
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
    before do
      @e1 = KPEnvironment.create!({:name => @env_name + '-succ1', 
                :organization => @organization, :prior => @environment})
      @e2 = KPEnvironment.create!({:name => @env_name + '-succ2', 
                :organization => @organization, :prior => @e1})
      
      @organization.environments << @e1
      @organization.environments << @e2
    end
    specify{ lambda {KPEnvironment.create!({:name => @env_name + '-succ3', 
              :organization => @organization, :prior => @e1})}.should raise_error(ActiveRecord::RecordInvalid)} 
  end
end






















