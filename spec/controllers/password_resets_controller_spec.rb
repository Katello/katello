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

describe PasswordResetsController do
  include LoginHelperMethods
  include LocaleHelperMethods

  before (:each) do
    set_default_locale
    login_user

    @testuser_username = "TestUser"
    @testuser_password = "foobar"
    @testuser_email = "TestUser@somewhere.com"
    @testuser_password_reset_token = "random_token_asdklfjasdlfkjadf"
    @testuser_password_reset_sent_at = Time.zone.now
    @testuser = mock_model(User, :username => @testuser_username, :password => @testuser_password,
                           :email => @testuser_email, :password_reset_token => @testuser_password_reset_token,
                           :password_reset_sent_at => @testuser_password_reset_sent_at)
  end

  describe "GET new" do
    it "successfully renders password reset request page" do
      get :new
      response.should render_template(:new)
      response.should be_success
    end
  end

  describe "POST create" do
    before (:each) do
      @params = {:username => @testuser_username, :email => @testuser_email}

      User.stub!(:find_by_username_and_email!).and_return(@testuser)
      @testuser.stub!(:send_password_reset)
    end

    it "should send an email with password reset details" do
      @testuser.should_receive(:send_password_reset)
      post :create, @params
      response.should be_success
    end

    it "should generate a notice to inform user of email sent" do
      controller.should_receive(:notice)
      post :create, @params
      response.should be_success
    end

    it_should_behave_like "bad request"  do
      let(:req) do
        bad_req = @params
        bad_req[:bad_foo] = "mwahaha"
        post :create, bad_req
      end
    end
  end

  describe "GET edit" do
    before (:each) do
      User.stub!(:find_by_password_reset_token!).and_return(@testuser)
    end

    it "successfully renders password reset edit page" do
      get :edit, :id => @testuser_password_reset_token
      response.should render_template(:edit)
      response.should be_success
    end
  end

  describe "PUT update" do
    before (:each) do
      @new_password = "mynewpassword"
      @params = {:id => @testuser_password_reset_token, :user => {:password => @new_password}}

      User.stub!(:find_by_password_reset_token!).and_return(@testuser)
      @testuser.stub!(:update_attributes!).and_return
    end

    it "should update the user's password and reset the token details" do
      @testuser.should_receive(:update_attributes!).with("password" => @new_password, "password_reset_token" => nil, "password_reset_sent_at" => nil)
      put :update, @params
      response.should be_success
    end

    it "should generate a notice" do
      controller.should_receive(:notice)
      put :update, @params
      response.should be_success
    end

    it "should generate an error notice, if exception raised" do
      @testuser.stub!(:update_attributes!).and_raise(Exception)
      controller.should_receive(:notice).with(anything(), hash_including(:level => :error))
      put :update, @params
    end
    it_should_behave_like "bad request"  do
      let(:req) do
        bad_req = @params
        bad_req[:user][:bad_foo] = "mwahaha"
        put :update, bad_req
      end
    end


  end

  describe "GET email_logins" do
    before (:each) do
      @params = {:email => @testuser_email}

      User.stub!(:where).and_return([@testuser])
      UserMailer.stub!(:send_logins)
    end

    it "should send an email with the user's logins" do
      UserMailer.should_receive(:send_logins)
      post :email_logins, @params
      response.should be_success
    end

    it "should generate a notice to inform user of email sent" do
      controller.should_receive(:notice)
      post :email_logins, @params
      response.should be_success
    end
  end
end
