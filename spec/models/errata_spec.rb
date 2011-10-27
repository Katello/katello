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

describe Glue::Pulp::Errata do

  before (:each) do
    disable_errata_orchestration
    disable_org_orchestration
    @organization = Organization.create!(:name => 'test_organization', :cp_key => 'test_organization')
    @locker = @organization.locker

    @repo = Glue::Pulp::Repo.new(:id => "repo-123")
    @repo2 = Glue::Pulp::Repo.new(:id => "repo-456")
    @env = KTEnvironment.create!(:name => "Dev", :prior => @organization.locker, :organization_id => @organization.id)
    Glue::Pulp::Repo.stub(:new => @repo)
  end
  
  context "Find errata" do
    it "should call pulp find errata api" do
      
      Pulp::Errata.should_receive(:find).once.with('1')
      Glue::Pulp::Errata.find('1')
    end
    
    it "should create new Errata" do

      Glue::Pulp::Errata.should_receive(:new)
      Glue::Pulp::Errata.find('1')
    end
  end

  describe "Filter errata" do
    it "should be able to search all errata of given type for given environment" do
      products_with_repo = [mock(Product, :repos => [@repo]), mock(Product, :repos => [@repo2])]
      @env.stub(:products => products_with_repo)
      KTEnvironment.stub(:find => @env)

      filter = { :type => "security", :environment_id => @env.id }
      Pulp::Repository.should_receive(:errata).once.with(@repo.id, filter.except(:environment_id)).and_return(RepoTestData::REPO_ERRATA[0..0])
      Pulp::Repository.should_receive(:errata).once.with(@repo2.id, filter.except(:environment_id)).and_return(RepoTestData::REPO_ERRATA[1..1])

      Glue::Pulp::Errata.filter(filter).should == RepoTestData::REPO_ERRATA
    end

    it "should be able to search all errata of given type and repo" do
      filter = { :type => "security", :repoid => "repo-123" }
      Pulp::Repository.should_receive(:errata).once.with(@repo.id, filter.except(:repoid)).and_return(RepoTestData::REPO_ERRATA[0..0])
      Glue::Pulp::Errata.filter(filter).should == RepoTestData::REPO_ERRATA[0..0]
    end

    it "should be able to search all errata of given type and product" do
      filter = { :type => "security", :product_id => "product-123", :environment_id => @env.id }
      product_with_repo = mock(Product, :repos => [@repo, @repo2])

      ::Product.should_receive(:find_by_cp_id!).with("product-123").and_return(product_with_repo)
      Pulp::Repository.should_receive(:errata).once.with(@repo.id, filter.slice(:type)).and_return(RepoTestData::REPO_ERRATA[0..0])
      Pulp::Repository.should_receive(:errata).once.with(@repo2.id, filter.slice(:type)).and_return(RepoTestData::REPO_ERRATA[1..1])

      Glue::Pulp::Errata.filter(filter).should == RepoTestData::REPO_ERRATA
    end
  end
  
end


def disable_errata_orchestration
  Pulp::Errata.stub(:find).and_return({})
end
