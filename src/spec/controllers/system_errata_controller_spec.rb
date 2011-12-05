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

describe SystemErrataController do
  include LoginHelperMethods
  include LocaleHelperMethods
  include SystemHelperMethods
  include AuthorizationHelperMethods

  describe "main" do
    let(:uuid) { '1234' }

    before (:each) do
      login_user
      set_default_locale

      @organization = setup_system_creation
      @environment = KTEnvironment.new(:name => 'test', :prior => @organization.locker.id, :organization => @organization)
      @environment.save!

      controller.stub!(:errors)
      controller.stub!(:notice)

      Candlepin::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
      Candlepin::Consumer.stub!(:update).and_return(true)

      Pulp::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
      Pulp::Consumer.stub!(:update).and_return(true)
    end

    describe "viewing systems" do
      before (:each) do
        100.times{|a| System.create!(:name=>"bar#{a}", :environment => @environment, :cp_type=>"system", :facts=>{"Test" => ""})}
        @systems = System.select(:id).where(:environment_id => @environment.id).all.collect{|s| s.id}
      end

      describe 'and requesting individual data' do
        before (:each) do
          @system = System.create!(:name=>"verbose", :environment => @environment, :cp_type=>"system", :facts=>{"Test1"=>1, "verbose_facts" => "Test facts"})

          Pulp::Consumer.stub!(:errata).and_return([])
        end
        
        it "should be successful" do
          get :index, :system_id => @system.id
          response.should be_success
        end

        it "should render errata template" do
          get :index, :system_id => @system.id
          response.should render_template("index")
        end
      end
    end
  end
end
