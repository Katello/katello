require 'katello_test_helper'
require 'rake'

module Katello
  class UpdateSubscriptionFacetBackendDataTest < ActiveSupport::TestCase
    def setup
      Rake.application.rake_require 'katello/tasks/update_subscription_facet_backend_data'

      Rake::Task['katello:update_subscription_facet_backend_data'].reenable
      Rake::Task.define_task(:environment)
      @host = hosts(:one)
      @host.organization = get_organization
    end

    def test_run
      Katello::Host::SubscriptionFacet.where("id != #{@host.subscription_facet.id}").destroy_all
      Katello::Host::SubscriptionFacet.any_instance.stubs(:host).returns(@host)
      Katello::Candlepin::Consumer.any_instance.stubs(:consumer_attributes).returns(:facts => {:foo => :bar})
      Katello::Resources::Candlepin::Consumer.stubs(:virtual_guests).returns([])
      Katello::Resources::Candlepin::Consumer.stubs(:virtual_host).returns(nil)

      Katello::Host::SubscriptionFacet.expects(:update_facts).with(@host, { :foo => :bar }).once

      Rake.application.invoke_task('katello:update_subscription_facet_backend_data')
    end
  end
end
