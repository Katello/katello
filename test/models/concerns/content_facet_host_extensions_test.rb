# encoding: utf-8

require 'katello_test_helper'
require 'support/host_support'

module Katello
  class ContentFacetHostExtensionsBaseTest < ActiveSupport::TestCase
    let(:library) { katello_environments(:library) }
    let(:view)  { katello_content_views(:library_dev_view) }
    let(:view2) { katello_content_views(:library_dev_staging_view) }
    let(:dev) { katello_environments(:dev) }
    let(:empty_host) { ::Host::Managed.create!(:name => 'foobar', :managed => false) }
    let(:host) do
      FactoryGirl.create(:host, :with_content, :content_view => view,
                                     :lifecycle_environment =>  library)
    end
  end

  class ContentFacetHostExtensionsTest < ContentFacetHostExtensionsBaseTest
    def test_in_content_view_environment
      assert_includes ::Host.in_content_view_environment(:content_view => view), host
      assert_includes ::Host.in_content_view_environment(:lifecycle_environment => library), host
      assert_includes ::Host.in_content_view_environment(:content_view => view, :lifecycle_environment => library), host
      refute_includes ::Host.in_content_view_environment(:content_view => view, :lifecycle_environment => dev), host
    end

    def test_content_facet_update
      host.update_attributes!(:content_facet_attributes => { :content_view_id => view2.id })
      host.reload.content_facet.reload

      refute_nil host.content_facet.uuid # not reset to nil
      assert_equal library.id, host.content_facet.lifecycle_environment_id # unchanged
      assert_equal view2.id, host.content_facet.content_view_id # changed
    end
  end
end
