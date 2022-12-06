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
      ::Host::Managed.any_instance.stubs(:update_candlepin_associations)

      ENV['HOSTS'] = nil
      ENV['DRYRUN'] = nil
      ENV['USE_NAME'] = nil
      setup_two_hosts
    end

    def setup_two_hosts
      mac = '52:54:00:bc:d3:72'
      @host1 = FactoryBot.create(:host)
      @host1.update!(:name => 'foobar.example.com')
      @host1.primary_interface.update!(:mac => mac)

      @host2 = FactoryBot.create(:host, :with_content, :with_subscription, :name => 'foobar', :content_view => @content_view, :lifecycle_environment => @environment)
      @host2.update!(:name => 'foobar')
      @host2.primary_interface.update!(:mac => mac)
    end

    def test_unify_all
      Rake.application.invoke_task('katello:unify_hosts')

      assert_nil ::Host.find_by(:id => @host2.id)
      refute_nil @host1.reload.subscription_facet.uuid
    end

    def test_unify_hosts_dry_run
      ENV['DRYRUN'] = 'true'
      Rake.application.invoke_task('katello:unify_hosts')

      refute_nil ::Host.find_by(:id => @host2.id)
      assert_nil @host1.reload.subscription_facet
    end

    def test_unify_two
      ENV['HOSTS'] = 'foobar.example.com,foobar'

      Rake.application.invoke_task('katello:unify_hosts')

      assert_nil ::Host.find_by(:id => @host2.id)
      refute_nil @host1.reload.subscription_facet.uuid
    end

    def test_unify_two_compute_resource
      ENV['HOSTS'] = 'foobar.example.com,foobar'
      @host2.compute_resource = FactoryBot.create(:compute_resource, :ec2)
      @host2.uuid = SecureRandom.uuid
      @host2.save!
      Rake.application.invoke_task('katello:unify_hosts')

      refute_nil ::Host.find_by(:id => @host2.id)
      refute_nil @host2.reload.subscription_facet.uuid
    end

    def test_unify_two_managed
      ENV['HOSTS'] = 'foobar.example.com,foobar'
      @host2.managed = true
      @host2.save(:validate => false)
      Rake.application.invoke_task('katello:unify_hosts')

      refute_nil ::Host.find_by(:id => @host2.id)
      refute_nil @host2.reload.subscription_facet.uuid
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
      @host1.primary_interface.update!(:mac => '52:bc:bc:bc:bc:bc')

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

    def test_use_name
      @host1.primary_interface.update!(:mac => '52:bc:bc:bc:bc:bc')
      ENV['USE_NAME'] = 'true'
      Rake.application.invoke_task('katello:unify_hosts')

      assert_nil ::Host.find_by(:id => @host2.id)
      refute_nil @host1.reload.subscription_facet
    end

    def test_use_name_uppercase
      @host1.primary_interface.update!(:mac => '52:bc:bc:bc:bc:bc')
      @host2.name = @host1.name.upcase
      @host2.save!(:validate => false)

      ENV['USE_NAME'] = 'true'
      Rake.application.invoke_task('katello:unify_hosts')

      assert_nil ::Host.find_by(:id => @host2.id)
      refute_nil @host1.reload.subscription_facet
    end
  end
end
