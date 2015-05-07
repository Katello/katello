require 'katello_test_helper'

module Katello
  class ContentTypeTest < ActiveSupport::TestCase
    def test_package_type
      assert_equal(Package::CONTENT_TYPE, Katello.pulp_server.extensions.rpm.content_type)
    end

    def test_package_group_type
      assert_equal(PackageGroup::CONTENT_TYPE, Katello.pulp_server.extensions.package_group.content_type)
    end

    def test_erratum_type
      assert_equal(Erratum::CONTENT_TYPE, Katello.pulp_server.extensions.errata.content_type)
    end
  end
end
