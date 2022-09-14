require 'katello_test_helper'

module Katello
  class BulkItemsHelperTest < ActiveSupport::TestCase
    def test_select_all_errata
      bulk_params = { included: { ids: [], search: '' }, excluded: { ids: [] } }
      bulk_items = ::Katello::BulkItemsHelper.new(bulk_params: bulk_params,
        model_scope: ::Katello::Erratum.all,
        key: :errata_id).fetch

      assert_equal_arrays ::Katello::Erratum.all.to_a, bulk_items
    end
  end
end
