require 'katello_test_helper'

module Katello
  module Hostgroup
    class ContentFacetTest < ActiveSupport::TestCase
      let(:library) { katello_environments(:library) }
      let(:dev) { katello_environments(:dev) }
      let(:view) { katello_content_views(:library_dev_view) }
      let(:cve) { katello_content_view_environments(:library_dev_view_library) }
      let(:hostgroup) { ::Hostgroup.new(:name => 'test-hg') }

      def setup
        @content_facet = Katello::Hostgroup::ContentFacet.new(:hostgroup => hostgroup)
      end

      # Test direct CVE assignment (primary method for UI form)
      def test_content_view_environment_assignment
        @content_facet.content_view_environment = cve
        assert @content_facet.valid?
        assert_equal cve, @content_facet.content_view_environment
      end

      def test_nil_content_view_environment_succeeds
        # Nil is valid (inheriting from parent)
        @content_facet.content_view_environment = nil
        assert @content_facet.valid?
      end

      # Test virtual attribute setters (API backwards compatibility)
      def test_both_content_view_and_lifecycle_environment_succeeds
        @content_facet.content_view_id = view.id
        @content_facet.lifecycle_environment_id = library.id
        assert @content_facet.valid?
        assert_equal cve, @content_facet.content_view_environment
      end

      def test_update_with_both_content_view_and_lifecycle_environment_succeeds
        # Create with valid CVE
        @content_facet.content_view_environment = cve
        @content_facet.save!

        # Update using virtual attributes (API backwards compat)
        new_facet = Katello::Hostgroup::ContentFacet.find(@content_facet.id)
        new_cv = katello_content_views(:acme_default)
        new_cve = katello_content_view_environments(:library_default_view_environment)

        new_facet.content_view_id = new_cv.id
        new_facet.lifecycle_environment_id = library.id

        assert new_facet.valid?
        assert_equal new_cve, new_facet.content_view_environment
      end

      # Test object setters
      def test_content_view_setter
        @content_facet.content_view = view
        assert_equal view.id, @content_facet.content_view_id
      end

      def test_lifecycle_environment_setter
        @content_facet.lifecycle_environment = library
        assert_equal library.id, @content_facet.lifecycle_environment_id
      end

      # Test object getters with pending values (API backwards compat)
      def test_content_view_getter_with_pending_value
        @content_facet.content_view_id = view.id
        @content_facet.lifecycle_environment_id = library.id
        assert_equal view, @content_facet.content_view
      end

      def test_lifecycle_environment_getter_with_pending_value
        @content_facet.content_view_id = view.id
        @content_facet.lifecycle_environment_id = library.id
        assert_equal library, @content_facet.lifecycle_environment
      end

      # Test inheritance behavior via virtual attributes (API backwards compatibility)
      # When using the deprecated virtual attributes, clearing one clears both
      def test_clearing_content_view_for_inheritance_clears_both
        # Create with valid CVE
        @content_facet.content_view_environment = cve
        @content_facet.save!
        assert_not_nil @content_facet.content_view_environment_id

        # Reload and clear only CV using virtual attribute (simulating API call)
        @content_facet.reload
        @content_facet.content_view_id = nil

        # Both should be cleared for inheritance
        assert_nil @content_facet.content_view_environment
        assert @content_facet.valid?
      end

      def test_clearing_lifecycle_environment_for_inheritance_clears_both
        # Create with valid CVE
        @content_facet.content_view_environment = cve
        @content_facet.save!
        assert_not_nil @content_facet.content_view_environment_id

        # Reload and clear only LCE using virtual attribute (simulating API call)
        @content_facet.reload
        @content_facet.lifecycle_environment_id = nil

        # Both should be cleared for inheritance
        assert_nil @content_facet.content_view_environment
        assert @content_facet.valid?
      end

      def test_clearing_content_view_with_blank_string_clears_both
        # Create with valid CVE
        @content_facet.content_view_environment = cve
        @content_facet.save!

        # Reload and clear with blank string (simulating form submission via API)
        @content_facet.reload
        @content_facet.content_view_id = ''

        # Both should be cleared
        assert_nil @content_facet.content_view_environment
        assert @content_facet.valid?
      end
    end
  end
end
