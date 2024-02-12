require "#{Katello::Engine.root}/test/support/auth_support"

module ControllerSupport
  include Katello::AuthorizationSupportMethods

  def check_permission(permission:, action:, request:, organizations:, locations:,
                       authorized: true, expect_404: false)
    permissions = permission.is_a?(Array) ? permission : [permission]

    permissions.each do |perm|
      user = User.unscoped.find(users(:restricted).id)
      as_admin do
        user.organizations = organizations unless organizations.blank?
        user.locations = locations unless locations.blank?
        setup_user_with_permissions(perm, user)
      end

      @controller.define_singleton_method(action) { head :no_content }

      login_user(user)
      request.call

      if authorized
        msg = "Expected response for #{action} to be a <success>, but was <#{response.status}> instead. \n" \
                 "permission -> #{permission.to_yaml}"
        assert((response.status >= 200) && (response.status < 300), msg)
      elsif expect_404
        msg = "404 expected for #{action}, got #{response.status} instead. \n" \
                "permission -> #{permission.to_yaml}"
        assert_equal 404, response.status, msg
      else
        msg = "Security Violation (403) expected for #{action}, got #{response.status} instead. \n" \
                "permission -> #{permission.to_yaml}"
        assert_equal 403, response.status, msg
      end
    end
  end

  def assert_protected_action(action_name, allowed_perms, denied_perms = [],
                              organizations = [], locations = [], expect_404: false, &block)
    assert_authorized(
        :permission => allowed_perms,
        :action => action_name,
        :request => block,
        :organizations => organizations,
        :locations => locations,
        :expect_404 => expect_404
    )

    unless denied_perms.empty?
      refute_authorized(
          :permission => denied_perms,
          :action => action_name,
          :request => block,
          :organizations => organizations,
          :locations => locations,
          :expect_404 => expect_404
      )
    end
  end

  def assert_protected_object(action_name, allowed_perms, denied_perms = [],
                              organizations = [], locations = [], &block)
    assert_protected_action(action_name, allowed_perms, denied_perms, organizations,
                            locations, expect_404: true, &block)
  end

  def assert_authorized(params)
    check_params = params.merge(authorized: true)
    check_permission(**check_params)
  end

  def refute_authorized(params)
    check_params = params.merge(authorized: false)
    check_permission(**check_params)
  end
end
