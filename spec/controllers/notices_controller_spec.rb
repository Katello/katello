require 'katello_test_helper'

module Katello
  describe NoticesController do
    include LocaleHelperMethods
    include OrganizationHelperMethods

    before :each do
      setup_controller_defaults
      @user = User.current
      @controller.stubs(:render_panel_direct).returns([])
    end

    describe "viewing notices" do
      before :each do
        20.times { |a| Notice.create!(:text => "bar#{a}", :level => :success, :user_notices => [UserNotice.new(:user => @user)]) }
        @notices = Notice.select(:id).where("text like 'bar%'").order("id desc").all.collect { |s| s.id }
      end

      it 'should show all user notices (katello)' do #TODO: headpin
        get :show
        must_respond_with(:success)
        must_render_template("show")
        assigns[:notices]
      end

      it 'should show all unread notices for a user (katello)' do #TODO: headpin
        @request.env['HTTP_ACCEPT'] = 'application/json'
        get :get_new
        must_respond_with(:success)
      end

      it 'should show the details for a specific notice (katello)' do #TODO: headpin
        n = Notice.create!(:text => "Test notice", :level => :success,
                           :details => "Notices success details.",
                           :user_notices => [UserNotice.new(:user => @user)])
        get :details, :id => n.id
        must_respond_with(:success)
      end

      it 'should throw an exception if the notice has no details (katello)' do #TODO: headpin
        Notice.create!(:text => "Test notice", :level => :success,
                       :user_notices => [UserNotice.new(:user => @user)])
        get :details, :id => 21
        response.must_respond_with(404)
      end
    end

    describe "deleting notices" do
      before :each do
        @controller.stubs(:render)
        10.times do |a|
          Notice.create!(:text => "bar#{a}",
                         :level => :success,
                         :user_notices => [UserNotice.new(:user => @user, :viewed => true)])
        end
      end

      it 'should allow all notices to be destroyed for a single user (katello)' do #TODO: headpin
        !UserNotice.where(:user_id => @user.id).count.wont_equal(0)
        delete :destroy_all
        must_respond_with(:success)
        UserNotice.where(:user_id => @user.id).count.must_equal(0)
      end
    end
  end
end
