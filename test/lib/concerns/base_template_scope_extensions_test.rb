require 'katello_test_helper'

module Katello
  class BaseTemplateScopeExtensionsTest < ActiveSupport::TestCase
    def setup
      @host = hosts(:one)
      @errata = katello_errata(:security)
    end

    def test_errata
      source = ::Foreman::Renderer::Source::String.new(
        name: 'Parameter',
        content: "<%= errata('#{@errata.errata_id}')['id'] %>"
      )
      scope = ::Foreman::Renderer.get_scope
      id = ::Foreman::Renderer.render(source, scope)

      refute_empty id
      assert_equal @errata.id.to_s, id
    end

    def test_host_redhat_subscriptions_consumed
      subscriptions = [
        stub(redhat?: false, quantity_consumed: 4),
        stub(redhat?: true, quantity_consumed: 15),
        stub(redhat?: true, quantity_consumed: 2)
      ]

      ::Katello::Candlepin::Consumer.any_instance.stubs(:entitlements).returns([])
      ::Katello::HostSubscriptionsPresenter.any_instance.expects(:subscriptions).returns(subscriptions)

      source = ::Foreman::Renderer::Source::String.new(
        name: 'Parameter',
        content: "<%= host_redhat_subscriptions_consumed(@host) %>"
      )
      scope = ::Foreman::Renderer.get_scope(host: @host)
      rendered = ::Foreman::Renderer.render(source, scope)

      # the custom pool should not be included in the summation
      assert_equal '17', rendered
    end
  end
end
