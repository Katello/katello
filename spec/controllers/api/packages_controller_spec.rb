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

describe Api::PackagesController do
  include LoginHelperMethods
  include AuthorizationHelperMethods

  let(:repo_id) {'f8ab5088-688e-4ce4-ade3-700aa4cbb070'}
  before(:each) do
    disable_authorization_rules
    login_user_api

    repo = OpenStruct.new(:packages => {})
    repo.stub(:packages).and_return([])
    Repository.stub(:find).with(repo_id).and_return(repo)

    package = OpenStruct.new(:repoids => [repo_id])
    Pulp::Package.stub(:find).once.with(1).and_return(package)
  end

  describe "get a listing of packages" do
    it "should call pulp find packages api" do
      Repository.should_receive(:find).with(repo_id)
      get 'index', :repository_id => repo_id
    end
  end

  describe "show a package" do
    it "should call pulp find package api" do
      Pulp::Package.should_receive(:find).once.with(1)
      get 'show', :id => 1, :repository_id => repo_id
    end
  end
end
