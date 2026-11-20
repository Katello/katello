require "#{Katello::Engine.root}/test/support/auth_support"

module ControllerSupport
  include Katello::AuthorizationSupportMethods

  # Asserts that a collection action's database reads do not grow with the page
  # size. The block receives a per_page value and must perform the request.
  # Every SELECT counts, including cached ones and reads outside Katello: a
  # per-row query can land on any table. Framework bookkeeping is excluded:
  # schema introspection runs lazily (so it lands on one request or another),
  # authentication resolves the current user a different number of times per
  # request depending on whether it is already set, and taxonomies are resolved
  # whenever a host relation is built.
  EXCLUDED_READ_SQL = /
    pg_catalog|pg_attribute|pg_class|pg_index|pg_type|pg_namespace|generate_subscripts|
    information_schema|
    FROM\s+"(?:
      ar_internal_metadata|schema_migrations|
      users|auth_sources|personal_access_tokens|roles|user_roles|taxonomies
    )"
  /x

  def assert_page_query_count_constant(small_per_page: 1, large_per_page: 3)
    counts = []
    sizes = []
    [small_per_page, large_per_page].each do |per_page|
      count = 0
      callback = lambda do |*args|
        sql = args.last[:sql].to_s
        count += 1 if sql.lstrip =~ /\ASELECT/i && sql !~ EXCLUDED_READ_SQL
      end
      ActiveSupport::Notifications.subscribed(callback, 'sql.active_record') do
        yield per_page
      end
      counts << count
      sizes << collection_result_size
    end

    assert_operator sizes.first, :>, 0, 'expected the small page to return results'
    assert_operator sizes.last, :>, sizes.first, 'expected the two per_page values to return different result counts'
    assert_equal counts.first, counts.last,
                 "expected the query count not to grow with the page size " \
                 "(per_page #{small_per_page}: #{counts.first}, per_page #{large_per_page}: #{counts.last})"
  end

  def collection_result_size
    body = JSON.parse(response.body)
    body.is_a?(Hash) ? Array(body['results']).size : body.size
  rescue JSON::ParserError
    0
  end

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
