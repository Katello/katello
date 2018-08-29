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
  end

  class ContentFacetHostExtensionsTest < ContentFacetHostExtensionsBaseTest
    def test_in_content_view_environment
      assert_includes ::Host.in_content_view_environment(:content_view => view), host
      assert_includes ::Host.in_content_view_environment(:lifecycle_environment => library), host
      assert_includes ::Host.in_content_view_environment(:content_view => view, :lifecycle_environment => library), host
      refute_includes ::Host.in_content_view_environment(:content_view => view, :lifecycle_environment => dev), host
    end

    def test_action_not_triggered_on_facet_no_change
      ForemanTasks.dynflow.world.expects(:plan).never
      host.update_attributes!(:content_facet_attributes => { :content_view_id => view.id })
    end

    def test_action_triggered_on_facet_update
      host.stubs(:execute_planned_action)

      ForemanTasks.dynflow.world
        .expects(:plan).with(::Actions::Katello::Host::Update, host)
        .returns(OpenStruct.new(error: false))
      host.update_attributes!(:content_facet_attributes => { :content_view_id => view2.id })
      if host.environment
        host.environment.organizations << host.organization
        host.environment.locations << host.location
      end

      host.reload
      host.content_facet.content_view_id = view.id
      ForemanTasks.dynflow.world
        .expects(:plan).with(::Actions::Katello::Host::Update, host)
        .returns(OpenStruct.new(error: false))
      host.save!

      host.reload
      ForemanTasks.dynflow.world
        .expects(:plan).with(::Actions::Katello::Host::Update, host)
        .returns(OpenStruct.new(error: false))
      host.update_attributes!(:content_facet_attributes => { :lifecycle_environment_id => dev.id })
    end

    def test_content_facet_update
      host.update_attributes!(:content_facet_attributes => { :content_view_id => view2.id })
      host.reload.content_facet.reload

      refute_nil host.content_facet.uuid # not reset to nil
      assert_equal library.id, host.content_facet.lifecycle_environment_id # unchanged
      assert_equal view2.id, host.content_facet.content_view_id # changed
    end

    def test_other_content_facet_update
      host.update_attributes!(:content_facet_attributes => { :content_source_id => proxy.id })
      host.reload.content_facet.reload
      refute_nil host.content_facet.uuid # not reset to nil
      assert_equal proxy.id, host.content_facet.content_source_id # changed
    end

    def test_content_facet_allows_individual_attribute_updates
      assert host.update_attributes(
        :content_facet_attributes => { content_view_id: view.id, lifecycle_environment_id: library.id })
      refute_nil host.content_facet
      assert host.update_attributes(:content_facet_attributes => { lifecycle_environment_id: dev.id})
      assert_equal dev.id, host.content_facet.lifecycle_environment_id
    end

    def test_content_facet_gets_ignored_on_new
      assert_nil empty_host.content_facet
      empty_host.content_facet_attributes = { :content_source_id => proxy.id }
      assert empty_host.valid?

      empty_host.reload
      assert_nil empty_host.content_facet

      empty_host.update_attributes(:content_facet_attributes => {})
      empty_host.reload
      assert_nil empty_host.content_facet

      empty_host.update_attributes(:content_facet_attributes => { content_view_id: view.id })
      empty_host.reload
      assert_nil empty_host.content_facet

      empty_host.update_attributes(:content_facet_attributes => { lifecycle_environment_id: library.id })
      empty_host.reload
      assert_nil empty_host.content_facet

      empty_host.update_attributes(:content_facet_attributes => { :lifecycle_environment_id => library.id, :content_view_id => view.id })
      empty_host.reload.content_facet.reload
      refute_nil empty_host.content_facet # not reset to nil
    end
  end
end
