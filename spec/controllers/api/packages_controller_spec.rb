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

  before(:each) do
    login_user_api
  end

  describe "get a listing of packages" do
    it "should call pulp find packages api" do
      Pulp::Repository.should_receive(:packages).once.with(1)
      get 'index', :repository_id => 1
    end
  end

  describe "show a package" do
    it "should call pulp find package api" do
      Pulp::Package.should_receive(:find).once.with('f8ab5088-688e-4ce4-ade3-700aa4cbb070')
      get 'show', :id => 'f8ab5088-688e-4ce4-ade3-700aa4cbb070'
    end
  end

end
