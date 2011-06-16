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

describe SystemsController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include SystemHelperMethods

  before (:each) do
    login_user
    set_default_locale
    setup_system_creation
  end
  
  describe "viewing systems" do
    before (:each) do
      150.times{|a| System.create!(:name=>"bar#{a}", :cp_type=>"system", :facts=>{"Test" => ""})}
    end

    it "should show the system 2 pane list" do
      get :index
      response.should be_success
      response.should render_template("index")
      assigns[:systems].should include System.find(8)
      assigns[:systems].should_not include System.find(30)
    end

    it "should return a portion of systems" do
      get :items, :offset=>25
      response.should be_success
      response.should render_template("list_items")
      assigns[:systems].should include System.find(30)
      assigns[:systems].should_not include System.find(8)
    end
    
  end

end
