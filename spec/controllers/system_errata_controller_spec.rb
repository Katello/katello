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

describe SystemErrataController, :katello => true do
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
      @environment = KTEnvironment.new(:name=>'test', :label=> 'test', :prior => @organization.library.id, :organization => @organization)
      @environment.save!

      controller.stub!(:errors)

      Resources::Candlepin::Consumer.stub!(:create).and_return({:uuid => uuid, :owner => {:key => uuid}})
      Resources::Candlepin::Consumer.stub!(:update).and_return(true)

    end

    describe "viewing systems" do
      before (:each) do
        20.times{|a| create_system(:name=>"bar#{a}", :environment => @environment, :cp_type=>"system", :facts=>{"Test" => ""})}
        @systems = System.select(:id).where(:environment_id => @environment.id).all.collect{|s| s.id}
      end

      describe 'and requesting errata' do
        before (:each) do
          @system = create_system(:name=>"verbose", :environment => @environment, :cp_type=>"system", :facts=>{"Test1"=>1, "verbose_facts" => "Test facts"})

          types = [Glue::Pulp::Errata::SECURITY, Glue::Pulp::Errata::ENHANCEMENT, Glue::Pulp::Errata::BUGZILLA]

          to_ret = []
          40.times{ |num|
            errata           = OpenStruct.new
            errata.id        = "8a604f44-6877-4c81-b6f9-#{num}"
            errata.errata_id = "RHSA-2011-01-#{num}"
            errata.type      = types[rand(3)]
            errata.release   = "Red Hat Enterprise Linux 6.0"
            to_ret << errata
          }
          System.any_instance.stub(:errata).and_return(to_ret)
        end

        describe 'on initial load' do
          it "should be successful" do
            get :index, :system_id => @system.id
            response.should be_success
          end

          it "should render errata template" do
            get :index, :system_id => @system.id
            response.should render_template("index")
          end
        end

        describe 'with an offset' do
          it "should be successful" do
            get :items, :system_id => @system.id, :offset => 25
            response.should be_success
          end

          it "should render errata items" do
            get :items, :system_id => @system.id, :offset => 25
            response.should render_template("items")
          end
        end

        describe 'with a filter type' do
          it "should be successful" do
            get :items, :system_id => @system.id, :offset => 5, :filter_type => 'BugFix'
            response.should be_success
          end

          it "should render errata items" do
            get :items, :system_id => @system.id, :offset => 5, :filter_type => 'BugFix'
            response.should render_template("items")
          end
        end

        describe 'with a bad filter type' do
          it "should be unsuccessful" do
            get :items, :system_id => @system.id, :offset => 5, :filter_type => 'Fake Type'
            response.should_not be_success
          end
        end
      end

      describe 'and installing errata' do

      end
    end
  end
end
