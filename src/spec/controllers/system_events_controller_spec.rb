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

describe SystemEventsController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include SystemHelperMethods
  include AuthorizationHelperMethods
  include UserHelperMethods
  describe "main" do
    let(:uuid) { '1234' }
    before (:each) do
      login_user(:mock => false)
      set_default_locale
      @organization = setup_system_creation
      @environment = KTEnvironment.create!(:name => 'test', :prior => @organization.locker.id, :organization => @organization)

      #controller.stub!(:errors)
      #controller.stub!(:notice)

      Candlepin::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
      Candlepin::Consumer.stub!(:update).and_return(true)

      Pulp::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
      Pulp::Consumer.stub!(:update).and_return(true)
    end

    describe "system tasks" do
      before do
        @system = System.create!(:name=>"bar", :environment => @environment, :cp_type=>"system", :facts=>{"Test" => ""})
        #create some tasks
        #@tasks = [
        #  @system.install_packages("foo, bar, bazz, geez"),
        #  @system.update_packages("foo, bar, bazz, geez"),
        #  @system.remove_packages("foo, bar, bazz, geez")
        #]
      end
      it "should call the right templates" do
        get :index, :system_id => @system.id
        response.should be_success
        response.should render_template("items")
      end
      context "shows the Tasks list" do

        before do
          User.current = @user
          stub_consumer_packages_install(pulp_task_without_error)
          @task = @system.install_packages("foo, bar, bazz, geez")
          get :index, :system_id => @system.id
        end
        specify{response.should be_success}
        #specify do
        #  response.should render_template("items",:with=> {:locals => [@system,1, @task]})
        #end
      end


    end


  end
end