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
require 'helpers/repo_test_data'

describe Glue::Pulp::Errata, :katello => true do

  before (:each) do
    disable_errata_orchestration
    disable_org_orchestration
    @organization = Organization.create!(:name=>'test_organization', :label=> 'test_organization')
    @library = @organization.library

    @repo = Repository.new(:pulp_id => "repo-123")
    @repo2 = Repository.new(:pulp_id => "repo-456")
    @env = KTEnvironment.create!(:name=>"Dev", :label=> "Dev", :prior => @organization.library, :organization_id => @organization.id)
  end
  
  context "Find errata" do
    it "should call pulp find errata api" do
      
      Runcible::Extensions::Errata.should_receive(:find_by_unit_id).once.with('1')
      Errata.find('1')
    end
    
    it "should create new Errata" do

      Errata.should_receive(:new)
      Errata.find('1')
    end
  end

  describe "Filter errata" do
    it "should be able to search all errata of given type for given environment" do
      products_with_repo = [mock(Product, :repos => [@repo]), mock(Product, :repos => [@repo2])]
      @env.stub(:products => products_with_repo)
      KTEnvironment.stub(:find => @env)
      filter = { :type => "security", :environment_id => @env.id }
      Errata.should_receive(:search).twice.and_return(Support.array_with_total(RepoTestData::REPO_ERRATA))
      Errata.filter(filter).first.id.should == RepoTestData::REPO_ERRATA.first["_id"]
    end

    it "should be able to search all errata of given type and repo" do
      filter = { :type => "security", :repoid => "repo-123" }
      Repository.should_receive(:find).once.with(filter[:repoid]).and_return(@repo)
      Errata.should_receive(:search).twice.and_return(Support.array_with_total(RepoTestData::REPO_ERRATA[0..0]))
      Errata.filter(filter).first.id.should == RepoTestData::REPO_ERRATA.first["_id"]
    end

    it "should be able to search all errata of given type and product" do
      filter = { :type => "security", :product_id => "product-123", :environment_id => @env.id }
      product_with_repo = mock(Product, :repos => [@repo, @repo2])

      ::Product.should_receive(:find_by_cp_id!).with("product-123").and_return(product_with_repo)
      Errata.should_receive(:search).twice.and_return(Support.array_with_total(RepoTestData::REPO_ERRATA))
      Errata.filter(filter).first.id.should == RepoTestData::REPO_ERRATA.first["_id"]
    end
  end
  
end


def disable_errata_orchestration
  Runcible::Extensions::Errata.stub(:find_by_unit_id).and_return({})
end
