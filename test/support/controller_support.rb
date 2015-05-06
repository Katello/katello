require "#{Katello::Engine.root}/test/support/auth_support"

module ControllerSupport
  include Katello::AuthorizationSupportMethods

  def check_permission(params)
    permissions = params[:permission].is_a?(Array) ? params[:permission] : [params[:permission]]

    permissions.each do |permission|
      user = User.find(users(:restricted))
      setup_user_with_permissions(permission, user)

      action = params[:action]
      req = params[:request]
      @controller.define_singleton_method(action) { render :nothing => true }

      login_user(user)
      req.call

      if params[:authorized]
        msg = "Expected response for #{action} to be a <success>, but was <#{response.status}> instead. \n" \
                 "permission -> #{permission.to_yaml}"
        assert((response.status >= 200) && (response.status < 300), msg)
      else
        msg = "Security Violation (403) expected for #{action}, got #{response.status} instead. \n" \
                "permission -> #{permission.to_yaml}"
        assert_equal 403, response.status, msg
      end
    end
  end

  def assert_protected_action(action_name, allowed_perms, denied_perms = [], &block)
    assert_authorized(
        :permission => allowed_perms,
        :action => action_name,
        :request => block
    )

    unless denied_perms.empty?
      refute_authorized(
          :permission => denied_perms,
          :action => action_name,
          :request => block
      )
    end
  end

  def assert_authorized(params)
    check_params = params.merge(authorized: true)
    check_permission(check_params)
  end

  def refute_authorized(params)
    check_params = params.merge(authorized: false)
    check_permission(check_params)
  end
end
