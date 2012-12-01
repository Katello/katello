module WardenSupport

  def login_user(user)
    request.env['warden'] = Class.new do
      define_method(:user) { user }
      define_method(:authenticate) { user }
      define_method(:authenticate!) { user }
      define_method(:raw_session) { Object.new }
      define_method(:logout) { true }
    end

    Api::ApiController.instance_eval do
      define_method(:require_user) { {} }
      define_method(:current_user) { user }
    end
  end
end
