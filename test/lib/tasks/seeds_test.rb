require 'test_helper'

class SeedsTest < ActiveSupport::TestCase
  setup do
    # Disable AR transactional fixtures as we use DatabaseCleaner's truncation
    # to empty the DB of fixtures for testing the seed script
    self.use_transactional_fixtures = false
    DatabaseCleaner.clean_with :truncation
    Setting.stubs(:[]).with(:administrator).returns("root@localhost")
    Setting.stubs(:[]).with(:send_welcome_email).returns(false)
    Katello::Repository.stubs(:ensure_sync_notification)
  end

  def seed
    # Authorisation is disabled usually when run from a rake db:* task
    User.current = FactoryGirl.build(:user, :admin => true)
    load File.expand_path("#{Rails.root}/db/seeds.rb", __FILE__)
  end

  teardown do
    self.use_transactional_fixtures = true
    User.current = nil
  end
end

class LocationsTest < SeedsTest
  test "don't create a default location if no locations exist" do
    Location.stubs(:exists?).returns(false)
    seed
    refute Location.default_location.present?
  end

  test "create a default location on seed on a fresh install" do
    with_env('SEED_LOCATION' => 'seed_test') do
      seed
    end
    assert Location.default_location.present?
    assert_equal "seed_test", Location.default_location.name
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
    template_names = ["Katello Kickstart Default", "Katello Kickstart Default User Data", "Katello Kickstart Default Finish", "subscription_manager_registration"]

    ProvisioningTemplate.where(:default => true, :vendor => "Katello").each do |template|
      assert template_names.include?(template.name)
      assert template.organizations.empty?
    end
  end
end

class PulpProxyTest < SeedsTest
  test "Make sure Pulp Proxy features exist" do
    seed
    assert Feature.find_by(:name => 'Pulp').present?
    assert Feature.find_by(:name => 'Pulp Node').present?
  end
end

class PermissionsTest < SeedsTest
  test "Make sure katello permissions got created exist" do
    seed
    assert Permission.pluck(:resource_type).grep(/Katello/).present?
  end
end

class MailNotificationsTest < SeedsTest
  test "Make sure mail notiffication got setup" do
    seed
    assert ::MailNotification.pluck(:name).grep(/katello/).present?
  end
end

class EnsureSyncNotificationsTest < SeedsTest
  test "Make sure sync notifications  notiffication got setup" do
    Katello::Repository.expects(:ensure_sync_notification). returns(true)
    seed
  end
end
