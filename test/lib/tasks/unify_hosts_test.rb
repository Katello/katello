require 'katello_test_helper'
require 'rake'

module Katello
  class UnifyHostsTest < ActiveSupport::TestCase
    def setup
      Rake.application.rake_require 'katello/tasks/unify_hosts'
      Rake::Task['katello:unify_hosts'].reenable
      Rake::Task.define_task(:environment)

      @content_view = katello_content_views(:acme_default)
      @environment = katello_environments(:library)

      Katello::Candlepin::Consumer.any_instance.stubs(:entitlement_status).returns(Katello::Candlepin::Consumer::ENTITLEMENTS_VALID)

      ENV['HOSTS'] = nil
      setup_two_hosts
    end

    def setup_two_hosts
      mac = '52:54:00:bc:d3:72'
      @host1 = FactoryGirl.create(:host)
      @host1.update_attributes!(:name => 'foobar.example.com')
      @host1.primary_interface.update_attributes!(:mac => mac)

      @host2 = FactoryGirl.create(:host, :with_content, :with_subscription, :name => 'foobar', :content_view => @content_view, :lifecycle_environment => @environment)
      @host2.update_attributes!(:name => 'foobar')
      @host2.primary_interface.update_attributes!(:mac => mac)
    end

    def test_unify_all
      Rake.application.invoke_task('katello:unify_hosts')

      assert_nil ::Host.find_by(:id => @host2.id)
      refute_nil @host1.reload.subscription_facet.uuid
    end

    def test_unify_two
      ENV['HOSTS'] = 'foobar.example.com,foobar'

      Rake.application.invoke_task('katello:unify_hosts')

      assert_nil ::Host.find_by(:id => @host2.id)
      refute_nil @host1.reload.subscription_facet.uuid
    end

    def test_unify_two_backwards
      ENV['HOSTS'] = 'foobar,foobar.example.com'

      Rake.application.invoke_task('katello:unify_hosts')

      assert_nil ::Host.find_by(:id => @host2.id)
      refute_nil @host1.reload.subscription_facet.uuid
    end

    def test_saves_invalid_host
      @host1.organization_id = nil
      @host1.managed = true
      @host1.save!(:validate => false)
      refute @host1.valid?

      Rake.application.invoke_task('katello:unify_hosts')

      assert_nil ::Host.find_by(:id => @host2.id)
      refute_nil @host1.reload.subscription_facet.uuid
    end

    def test_unify_all_no_mac_match
      @host1.primary_interface.update_attributes!(:mac => '52:bc:bc:bc:bc:bc')

      Rake.application.invoke_task('katello:unify_hosts')

      refute_nil ::Host.find_by(:id => @host2.id)
      assert_nil @host1.reload.subscription_facet
    end

    def test_skips_unify_if_registered
      Katello::Host::SubscriptionFacet.create!(:host => @host1, :uuid => 'abcd-efgh')

      Rake.application.invoke_task('katello:unify_hosts')

      refute_nil ::Host.find_by(:id => @host2.id)
      assert_equal 'abcd-efgh', @host1.reload.subscription_facet.uuid
    end
  end
end
