module WardenSupport
  DEFAULT_EXPECTED = [:authenticate!]

  def login_user(user, org=nil)

    request.env['warden'] = Class.new do
      define_method(:user) { user }
      define_method(:authenticate) { user }
      define_method(:authenticate!) { user }
      define_method(:raw_session) { {} }
      define_method(:logout) { true }
    end.new



    ApplicationController.instance_eval do
      define_method(:current_organization) do
        Organization.find(org.id)
      end
    end if org
    #ApplicationHelper.instance_eval do
    #  define_method(:user){user}
    #end
    Api::ApiController.instance_eval do
      define_method(:require_user) { {} }
      define_method(:current_user) { user }
    end
  end

  def with_logged_in_user(user, expected_methods = DEFAULT_EXPECTED)
    warden = Minitest::Mock.new
    warden.expect(:user, user) if expected_methods.include?(:user)
    warden.expect(:authenticate, user) if expected_methods.include?(:authenticate)
    warden.expect(:authenticate!, user) if expected_methods.include?(:authenticate!)
    warden.expect(:raw_session, Object.new) if expected_methods.include?(:raw_session)
    warden.expect(:logout, true) if expected_methods.include?(:logout)

    Api::ApiController.stub(:require_user, {}) do
      Api::ApiController.stub(:current_user, user) do
        yield
      end
    end

    warden.verify
  end
end
