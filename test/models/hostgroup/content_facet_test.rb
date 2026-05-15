require 'katello_test_helper'

module Katello
  module Hostgroup
    class ContentFacetTest < ActiveSupport::TestCase
      let(:library) { katello_environments(:library) }
      let(:dev) { katello_environments(:dev) }
      let(:view) { katello_content_views(:library_dev_view) }
      let(:cvenv) { katello_content_view_environments(:library_dev_view_library) }
      let(:hostgroup) { ::Hostgroup.new(:name => 'test-hg') }

      def setup
        @content_facet = Katello::Hostgroup::ContentFacet.new(:hostgroup => hostgroup)
      end

      def test_content_view_environment_assignment
        @content_facet.content_view_environment = cvenv
        assert @content_facet.valid?
        assert_equal cvenv, @content_facet.content_view_environment
      end

      def test_nil_content_view_environment_succeeds
        @content_facet.content_view_environment = nil
        assert @content_facet.valid?
      end

      def test_content_view_id_getter
        @content_facet.content_view_environment = cvenv
        assert_equal view.id, @content_facet.content_view_id
      end

      def test_lifecycle_environment_id_getter
        @content_facet.content_view_environment = cvenv
        assert_equal library.id, @content_facet.lifecycle_environment_id
      end

      def test_content_view_getter
        @content_facet.content_view_environment = cvenv
        assert_equal view, @content_facet.content_view
      end

      def test_lifecycle_environment_getter
        @content_facet.content_view_environment = cvenv
        assert_equal library, @content_facet.lifecycle_environment
      end

      def test_getters_nil_when_no_cvenv
        assert_nil @content_facet.content_view_id
        assert_nil @content_facet.lifecycle_environment_id
        assert_nil @content_facet.content_view
        assert_nil @content_facet.lifecycle_environment
      end

      def test_clearing_content_view_environment
        @content_facet.content_view_environment = cvenv
        @content_facet.save!
        assert_not_nil @content_facet.content_view_environment_id

        @content_facet.reload
        @content_facet.content_view_environment = nil

        assert_nil @content_facet.content_view_environment
        assert @content_facet.valid?
      end
    end
  end
end
