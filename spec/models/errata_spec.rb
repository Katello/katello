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
    it "should be able to search all errata of given type" do
      filter = { :type => "security" }
      Pulp::Errata.should_receive(:filter).once.with(filter).and_return(RepoTestData::ERRATA)
      Glue::Pulp::Errata.filter(filter)
    end

    it "should be able to search all errata of given type and repo" do
      filter = { :type => "security", :repoid => "repo-123" }
      repo_mock = Glue::Pulp::Repo.new()
      Glue::Pulp::Repo.should_receive(:new).and_return(repo_mock)
      Pulp::Errata.should_receive(:filter).once.with(filter.slice(:type)).and_return(RepoTestData::ERRATA)
      repo_mock.should_receive(:errata).and_return(RepoTestData::REPO_ERRATA.map{|e| Glue::Pulp::Errata.new(e)})
      Glue::Pulp::Errata.filter(filter).should == [RepoTestData::ERRATA[1]]
    end
  end
  
end


def disable_errata_orchestration
  Pulp::Errata.stub(:find).and_return({})
end
