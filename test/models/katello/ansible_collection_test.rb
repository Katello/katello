require 'katello_test_helper'

module Katello
  class AnsibleCollectionTest < ActiveSupport::TestCase
    def setup
      @collection = katello_ansible_collections(:collection_one)
    end

    def test_tag_search
      @collection.tags = [AnsibleTag.create(:name => :foo), AnsibleTag.create(:name => :bar)]

      assert_include AnsibleCollection.search_for("tag = foo"), @collection
    end
  end
end
