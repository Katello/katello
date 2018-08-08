require 'katello_test_helper'

module Katello
  class ContentTest < ActiveSupport::TestCase
    def setup
      @content = katello_contents(:some_content)
      @rhel_content = katello_contents(:rhel_content)
    end

    def test_product_search
      assert_include Katello::Content.search_for("product_name = #{@content.products.first.name}"), @content
    end

    def test_update_repo_name
      repo = katello_repositories(:rhel_7_x86_64)
      repo.root.update_attributes(:content_id => @rhel_content.cp_content_id)

      @rhel_content.name = "FOOBAR"
      @rhel_content.save!

      assert_includes repo.reload.name, "FOOBAR"
    end
  end
end
