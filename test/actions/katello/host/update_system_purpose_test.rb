require 'katello_test_helper'

module Katello::Host
  class UpdateSystemPurposeTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    let(:action_class) { ::Actions::Katello::Host::UpdateSystemPurpose }

    def setup
      User.current = users(:admin)
      @host = FactoryBot.create(:host, :with_subscription)
      @service_level = 'Standard'
      @purpose_role = 'Red Hat Enterprise Linux Server'
      @purpose_usage = 'Production'
      @purpose_addons = ['Addon One', 'Addon Two', 'Addon Two', '']
      @action = create_action action_class
    end

    def test_update_system_purpose
      plan_action @action, @host, @service_level, @purpose_role, @purpose_usage, @purpose_addons

      assert_equal(@host.subscription_facet.service_level, @service_level)
      assert_equal(@host.subscription_facet.purpose_role, @purpose_role)
      assert_equal(@host.subscription_facet.purpose_usage, @purpose_usage)
      assert_equal(@host.subscription_facet.purpose_addons.count, 2)
      assert_equal(@host.subscription_facet.purpose_addons.first.name, 'Addon One')
      assert_equal(@host.subscription_facet.purpose_addons.second.name, 'Addon Two')
    end

    def test_dont_clear_host_values_on_nil_params
      @host.subscription_facet.purpose_addons << katello_purpose_addons(:addon)
      @host.subscription_facet.service_level = @service_level
      @host.subscription_facet.purpose_role = @purpose_role
      @host.subscription_facet.purpose_usage = @purpose_usage

      plan_action @action, @host, nil, nil, nil, nil

      assert_equal(@host.subscription_facet.service_level, @service_level)
      assert_equal(@host.subscription_facet.purpose_role, @purpose_role)
      assert_equal(@host.subscription_facet.purpose_usage, @purpose_usage)
      assert_equal(@host.subscription_facet.purpose_addons.first.name, katello_purpose_addons(:addon).name)
    end

    def test_unset_value_with_empty_string_array
      @host.subscription_facet.purpose_addons << katello_purpose_addons(:addon)
      @host.subscription_facet.service_level = @service_level
      @host.subscription_facet.purpose_role = @purpose_role
      @host.subscription_facet.purpose_usage = @purpose_usage

      plan_action @action, @host, '', '', '', []

      assert_equal(@host.subscription_facet.service_level, "")
      assert_equal(@host.subscription_facet.purpose_role, "")
      assert_equal(@host.subscription_facet.purpose_usage, "")
      assert_equal(@host.subscription_facet.purpose_addons, [])
    end
  end
end
