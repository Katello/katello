require 'katello_test_helper'

module Katello
  class SeedsTest < ActiveSupport::TestCase
    setup do
      Setting.stubs(:[]).with(:administrator).returns("root@localhost")
      Setting.stubs(:[]).with(:send_welcome_email).returns(false)
      Setting.stubs(:[]).with(regexp_matches(/katello_default_/)).returns("Crazy Template")
      Setting.stubs(:[]).with(:default_location_subscribed_hosts).returns('')
      Setting.stubs(:[]).with(:default_location_puppet_content).returns('')
      Katello::Repository.stubs(:ensure_sync_notification)
    end

    def seed
      # Authorisation is disabled usually when run from a rake db:* task
      User.current = FactoryGirl.build(:user, :admin => true)
      load File.expand_path("#{Rails.root}/db/seeds.rb", __FILE__)
    end

    teardown do
      User.current = nil
    end
  end

  class LocationsTest < SeedsTest
    setup do
      Setting.stubs(:[]).with(:entries_per_page).returns(20)
      Location.skip_callback(:destroy, :before, :deletable?)
      Location.destroy_all
    end

    test "don't create a default location if no locations exist" do
      Location.stubs(:exists?).returns(false)
      seed
      refute Location.default_location_ids.present?
    end

    test "create a default location on seed on a fresh install" do
      with_env('SEED_LOCATION' => 'seed_test') do
        seed
      end
      Setting.unstub(:[])
      assert Location.default_location_ids.present?
      default_location = Location.find(Location.default_location_ids.first)
      assert_equal 'seed_test', default_location.title
    end
  end

  class OrganizationsTest < SeedsTest
    test "setup org bindings for every org in foreman" do
      org = Organization.create!(:name => "myOrg")
      ForemanTasks.expects(:sync_task).with(::Actions::Katello::Organization::Create, org)
      seed
    end
  end

  class ProvisioningTemplatesTest < SeedsTest
    test "Make sure provisioning templates exist" do
      seed
      assert ProvisioningTemplate.where(:default => true).exists?
      template_names = ["Katello Kickstart Default", "Katello Kickstart Default User Data", "Katello Kickstart Default Finish", "subscription_manager_registration", "Katello Atomic Kickstart Default"]

      ProvisioningTemplate.where(:default => true, :vendor => "Katello").each do |template|
        assert template_names.include?(template.name)
        refute_empty template.organizations
      end
    end
  end

  class PulpProxyTest < SeedsTest
    test "Make sure Pulp Proxy features exist" do
      seed
      assert Feature.find_by_name('Pulp').present?
      assert Feature.find_by_name('Pulp Node').present?
    end
  end

  class MailNotificationsTest < SeedsTest
    test "Make sure mail notification got setup" do
      seed
      assert MailNotification[:host_errata_advisory]
      assert MailNotification[:promote_errata]
      assert MailNotification[:sync_errata]
    end
  end

  class SubscriptionBookmarkstest < SeedsTest
    test "Ensure hypervisor bookmark is created" do
      seed
      refute Bookmark.where(:name => "list hypervisors").empty?
    end
  end
end
