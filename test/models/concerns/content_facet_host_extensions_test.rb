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
      FactoryBot.create(:host, :with_content,
                        :with_subscription, :content_view => view,
                        :lifecycle_environment => library)
    end
    let(:proxy) { FactoryBot.create(:smart_proxy, :url => 'http://fakepath.com/foo') }
    let(:proxy2) { FactoryBot.create(:smart_proxy, :url => 'http://fakepath.com/bar') }
  end

  class ContentFacetHostExtensionsTest < ContentFacetHostExtensionsBaseTest
    def test_in_content_view_environment
      assert_includes ::Host.in_content_view_environment(:content_view => view), host
      assert_includes ::Host.in_content_view_environment(:lifecycle_environment => library), host
      assert_includes ::Host.in_content_view_environment(:content_view => view, :lifecycle_environment => library), host
      refute_includes ::Host.in_content_view_environment(:content_view => view, :lifecycle_environment => dev), host
    end

    def test_action_not_triggered_on_facet_no_change
      host.reload
      host.expects(:update_candlepin_associations).never
      host.update!(:content_facet_attributes => { :content_source_id => nil })
    end

    def test_action_triggered_on_facet_cve_update
      host.reload
      host.expects(:update_candlepin_associations).twice
      host.content_facet.assign_single_environment(
        :content_view => view,
        :lifecycle_environment => dev
      )
      host.save!

      host.reload
      host.expects(:update_candlepin_associations).twice
      host.content_facet.assign_single_environment(
        :content_view => view2,
        :lifecycle_environment => dev
      )
      host.save!
    end

    def test_content_facet_cve_update
      host.expects(:update_candlepin_associations).twice
      host.content_facet.assign_single_environment(
        :content_view => view2,
        :lifecycle_environment => dev
      )
      host.save!
      host.reload.content_facet.reload

      refute_nil host.content_facet.uuid # not reset to nil
      host_cve = host.content_view_environments.first
      assert_equal dev.id, host_cve.environment_id # unchanged
      assert_equal view2.id, host_cve.content_view_id # changed
    end

    def test_other_content_facet_update
      host = FactoryBot.create(:host, :with_content,
                        :with_subscription, :content_view => view,
                        :lifecycle_environment => library)
      host.subscription_facet.expects(:backend_update_needed?).returns(false)
      host.update!(:content_facet_attributes => { :content_source_id => proxy.id })
      host.reload.content_facet.reload
      refute_nil host.content_facet.uuid # not reset to nil
      assert_equal proxy.id, host.content_facet.content_source_id # changed
    end

    def test_content_facet_allows_individual_attribute_updates
      host.reload
      assert host.update(
        :content_facet_attributes => { content_source_id: proxy.id })
      refute_nil host.content_facet
      assert host.update(:content_facet_attributes => { content_source_id: proxy2.id })
      assert_equal proxy2.id, host.content_facet.content_source_id
    end
  end
end
