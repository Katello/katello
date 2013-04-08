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

describe NoticesController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include OrganizationHelperMethods

  before (:each) do
    @user = login_user :mock => false
    set_default_locale
    controller.stub(:render_panel_direct).and_return([])
  end

  describe "viewing notices" do
    before (:each) do
      20.times{|a| Notice.create!(:text=>"bar#{a}", :level=>:success, :user_notices=>[UserNotice.new(:user => @user)])}
      @notices = Notice.select(:id).where("text like 'bar%'").order("id desc").all.collect{|s| s.id}
    end

    it 'should show all user notices', :katello => true do #TODO headpin
      get :show
      response.should be_success
      response.should render_template("show")
      assigns[:notices]

    end

    it 'should show all unread notices for a user', :katello => true do #TODO headpin
      @request.env['HTTP_ACCEPT'] = 'application/json'
      get :get_new
      response.should be_success
    end

    it 'should show the details for a specific notice', :katello => true do #TODO headpin
      n = Notice.create!(:text=>"Test notice", :level=>:success,
                    :details=>"Notices success details.",
                    :user_notices=>[UserNotice.new(:user => @user)])
      get :details, :id=>n.id
      response.should be_success
    end

    it 'should throw an exception if the notice has no details', :katello => true do #TODO headpin
      Notice.create!(:text=>"Test notice", :level=>:success,
                    :user_notices=>[UserNotice.new(:user => @user)])
      get :details, :id=>21
      response.should_not be_success
    end
  end

  describe "deleting notices" do
    before (:each) do
      controller.stub!(:render)
      10.times { |a| Notice.create!(:text => "bar#{a}",
                                    :level => :success,
                                    :user_notices => [UserNotice.new(:user => @user, :viewed => true)]) }
    end

    it 'should allow all notices to be destroyed for a single user', :katello => true do #TODO headpin
      UserNotice.count.should == 10
      Notice.count.should == 10
      delete :destroy_all
      response.should be_success
      Notice.count.should == 0
      UserNotice.count.should == 0
    end
  end

end
