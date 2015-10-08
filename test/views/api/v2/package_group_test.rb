require 'katello_test_helper'

module Katello
  class PackageGroupViewTest < ActiveSupport::TestCase
    def setup
      @group = katello_package_groups(:server_pg)
    end

    def test_base
      assert_service_not_used(Pulp::PackageGroup) do
        render_rabl('katello/api/v2/package_groups/base.json', @group)
      end
    end

    def test_show
      assert_service_used(Pulp::PackageGroup) do
        render_rabl('katello/api/v2/package_groups/show.json', @group)
      end
    end
  end
end
