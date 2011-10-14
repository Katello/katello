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

require 'spec_helper.rb'

describe Api::DistributionsController do
  include LoginHelperMethods

  before(:each) do
    login_user_api
  end

  describe "get a listing of distributions" do
    
    before(:each) do
      @repo = mock(Glue::Pulp::Repo)
    end    
    
    it "should call pulp find repo api" do
      
      Glue::Pulp::Repo.should_receive(:find).once.with(1).and_return(@repo)
      @repo.should_receive(:distributions)
      
      get 'index', :repository_id => 1
    end
  end

  describe "show a distribution" do
    it "should call pulp find distribution api" do
      Glue::Pulp::Distribution.should_receive(:find).once.with(1)
      get 'show', :id => 1
    end
  end

end

