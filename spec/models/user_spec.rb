# encoding: UTF-8
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

describe User do

  include OrchestrationHelper
  include AuthorizationHelperMethods
  include OrganizationHelperMethods

  USERNAME = "testuser"
  PASSWORD = "password1234"
  EMAIL = "testuser@somewhere.com"

  INVALID_USERNAME = (0...260).map{ ('a'..'z').to_a[rand(26)] }.join

  let(:to_create_simple) do
    {
      :username => USERNAME,
      :password => PASSWORD,
      :email => EMAIL
    }
  end

  let(:to_create_invalid_user) do
    {
      :username => INVALID_USERNAME,
      :password => PASSWORD,
      :email => EMAIL
    }
  end

  describe "User shouldn't" do
    before(:each) do
      disable_user_orchestration
      AppConfig.warden = 'database'
    end

    it "be able to create" do
      user = User.new(to_create_invalid_user)
      user.should_not be_valid
      user.errors[:username].should include("cannot contain more than 64 characters")
    end

  end

  describe "Users in LDAP should" do
    before(:each) do
      disable_user_orchestration
      AppConfig.warden = 'ldap'
      @user = User.create_ldap_user!('testuser')
    end

    after(:each) do
      AppConfig.warden = 'database'
    end

    it 'be able to create' do
      u = User.find_by_username('testuser')
      u.should_not be_nil
    end

    it 'not have an email' do
      u = User.find_by_username('testuser')
      u.email.should be_nil
    end

    it "have its own role" do
      #pending "implement own_role functionality"
      @user.own_role.should_not be_nil
    end

    it "have a default org" do
      disable_org_orchestration
      @org = Organization.create!(:name=>'test_org', :label=> 'test_org')
      @user.default_org = @org
      @user.save!
      @user.stub!(:allowed_organizations).and_return([@org])
      @user.default_org.should == @org
    end

    it "have permission for two orgs" do
      disable_org_orchestration
      org = Organization.create!(:name=>'test_organization', :label=> 'test_organization')
      moreorg = Organization.create!(:name=>'another_test_organization', :label=> 'another_test_organization')
      allow(@user.own_role, [:read], :providers, nil, org)
      allow(@user.own_role,[:read], :providers, nil, moreorg)
      @user.allowed_organizations.size.should == 2
    end

    specify { @user.cp_oauth_header.should == {'cp-user' => @user.username}}
    specify { @user.pulp_oauth_header.should == {'pulp-user' => @user.username}}

    it "be able to set default_environment" do
      disable_org_orchestration
      @organization = Organization.create!(:name=>'test_org', :label=> 'test_org')
      @environment = KTEnvironment.create!(:name=>'test', :label=> 'test', :prior => @organization.library.id,
                                           :organization => @organization)

      @user.default_environment = @environment
      @user.reload
      @user.default_environment.should == @environment
    end
  end

  it "should allow email address as username", :katello => false do
    disable_user_orchestration
    AppConfig.warden = 'database'
    User.create!(:username => EMAIL, :password => PASSWORD, :email => EMAIL)
    u = User.find_by_username(EMAIL)
    u.should_not be_nil
  end

  describe "User should" do
    before(:each) do
      disable_user_orchestration
      AppConfig.warden = 'database'
      @user = User.create!(to_create_simple)
      current_user = @user
      User.stub(:current).and_return(current_user)
    end

    it "be able to create" do
      u = User.find_by_username("testuser")
      u.should_not be_nil
    end

    it "have ASCII username", :katello => true do
      non_ascii = {
        :username => 'Cuiabá_user1',
        :password => PASSWORD,
        :email => EMAIL
      }
      utf8 = nil
      begin
        utf8 = User.create!(non_ascii)
      rescue ActiveRecord::RecordInvalid
      end
      utf8.should be_nil
      u = User.find_by_username("Cuiabá_user1")
      u.should be_nil

    end


    it "have its own role" do
      #pending "implement own_role functionality"
      @user.own_role.should_not be_nil
    end

    it "have a default org" do
      disable_org_orchestration
      @org = Organization.create!(:name=>'test_org', :label=> 'test_org')
      @user.default_org = @org
      @user.save!
      allow(@user.own_role, [:read], :providers, nil, @org)
      @user.default_org.should == @org
    end

    it "have permission for two orgs" do
      disable_org_orchestration
      org = Organization.create!(:name=>'test_organization', :label=> 'test_organization')
      moreorg = Organization.create!(:name=>'another_test_organization', :label=> 'another_test_organization')
      allow(@user.own_role, [:read], :providers, nil, org)
      allow(@user.own_role,[:read], :providers, nil, moreorg)
      @user.allowed_organizations.size.should == 2
    end

    specify { @user.cp_oauth_header.should == {'cp-user' => @user.username}}
    specify { @user.pulp_oauth_header.should == {'pulp-user' => @user.username}}

    it "be able to set default_environment" do
      disable_org_orchestration
      @organization = Organization.create!(:name=>'test_org', :label=> 'test_org')
      @environment = KTEnvironment.create!(:name=>'test', :label=> 'test', :prior => @organization.library.id,
                                           :organization => @organization)

      @user.default_environment = @environment
      @user.reload
      @user.default_environment.should == @environment
    end

    it "be able to find users by default environment" do
      disable_org_orchestration
      @organization = Organization.create!(:name=>'test_org', :label=> 'test_org')
      @environment = KTEnvironment.create!(:name=>'test', :label=> 'test', :prior => @organization.library.id,
                                           :organization => @organization)

      @user.default_environment = @environment
      User.find_by_default_environment(@environment.id).first.should == @user
    end

    it "should unset default env after environment gets deleted" do
      disable_org_orchestration
      @organization = Organization.create!(:name=>'test_org', :label=> 'test_org')
      @environment = KTEnvironment.create!(:name=>'test', :label=> 'test', :prior => @organization.library.id,
                                           :organization => @organization)

      @user.default_environment = @environment
      @environment.destroy
      @user.default_environment.should == nil
      User.find_by_default_environment(@environment.id).should == []
    end
  end

  context "Pulp orchestration", :katello => true do
    context "on create" do

      before(:each) { disable_user_orchestration }

      it "should call pulp user create api during user creation" do
        Resources::Pulp::User.should_receive(:create).once.with(hash_including(:login => USERNAME, :name => USERNAME)).and_return({})
        User.create!(to_create_simple)
      end

      it "should call pulp role api during user creation" do
        Resources::Pulp::Roles.should_receive(:add).once.with("super-users", USERNAME).and_return(true)
        User.create!(to_create_simple)
      end
    end

    context "on destroy" do

      before(:each) do
        disable_user_orchestration
        @user = User.create!(to_create_simple)

        current_user = mock_model(User, :id=>1, :username=>"test_mock_user", :password=>"Password")
        User.stub(:current).and_return(current_user)
      end

      it "should call pulp user delete api during user deletion" do
        Resources::Pulp::User.should_receive(:destroy).once.with(USERNAME).and_return(200)
        @user.destroy
      end

      it "should call pulp role api during user deletion" do
        Resources::Pulp::Roles.should_receive(:remove).once.with("super-users", USERNAME).and_return(true)
        @user.destroy
      end
    end
  end

  context "retaining search history" do
    describe "display attribute filter" do
      before(:each) { @user = User.new }

      it "should filter out empty display attributes" do
        ["name:", " name:", "name: "].each {|attr| @user.empty_display_attributes?(attr).should == true}
      end

      it "should leave non-empty display attributes" do
        ["name:blah", "name: blah", " name:blah", "name:blah "].each {|attr| @user.empty_display_attributes?(attr).should == false}
      end

      it "should leave non-display attributes" do
        ["name", "name ", " name", "name blah"].each {|attr| @user.empty_display_attributes?(attr).should == false}
      end
    end

    describe "persisting search history" do
      let(:path) { "/blah" }
      before(:each) do
        disable_user_orchestration
        @user = User.create!(to_create_simple)
      end

      it "should not persist empty searches" do
        ["name:", "", " "].each do |attr|
          @user.create_or_update_search_history(path, attr)
          @user.search_histories.where(:path => "/blah").should be_empty
        end
      end

      it "should persist non-empty searches" do
        ["name:blah", "abracadabra"].each do |attr|
          @user.create_or_update_search_history(path, attr)
          @user.search_histories.where(:path => "/blah", :params => attr).size.should == 1
        end
      end
    end
  end


end
