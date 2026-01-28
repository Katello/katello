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
  end
end
