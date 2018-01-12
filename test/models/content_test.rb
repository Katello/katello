require 'katello_test_helper'

module Katello
  class ContentTest < ActiveSupport::TestCase
    def setup
      @content = katello_contents(:some_content)
    end

    def test_product_search
      assert_include Katello::Content.search_for("product_name = #{@content.products.first.name}"), @content
    end
  end
end
