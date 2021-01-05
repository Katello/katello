require 'katello_test_helper'
require 'foreman/renderer'
require 'foreman/renderer/source/string'

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
      redhat_product = katello_products(:redhat)
      fedora_product = katello_products(:fedora)

      redhat_pool = FactoryBot.create(:katello_pool, cp_id: '12345', products: [redhat_product])
      custom_pool = FactoryBot.create(:katello_pool, cp_id: '6789', products: [fedora_product])

      @host.subscription_facet.pools << redhat_pool
      @host.subscription_facet.pools << custom_pool

      entitlements = [
        {
          'pool' => {
            'id' => redhat_pool.cp_id
          },
          quantity: 15
        },
        {
          'pool' => {
            'id' => custom_pool.cp_id
          },
          quantity: 4
        }
      ]

      ::Katello::Candlepin::Consumer.any_instance.expects(:entitlements).returns(entitlements)

      source = ::Foreman::Renderer::Source::String.new(
        name: 'Parameter',
        content: "<%= host_redhat_subscriptions_consumed(@host) %>"
      )
      scope = ::Foreman::Renderer.get_scope(host: @host)
      rendered = ::Foreman::Renderer.render(source, scope)

      # the custom pool should not be included in the summation
      assert_equal '15', rendered
    end
  end
end
