require 'katello_test_helper'

module Katello
  class OrganizationCreatorTest < ActiveSupport::TestCase
    def test_seed
      org = FactoryBot.build(:organization)
      creator = Katello::OrganizationCreator.new(org)

      creator.seed!

      validate_creator(creator)
      validate_org(org)
    end

    def test_seed_preexisting
      org = FactoryBot.build(:organization)

      creator_one = Katello::OrganizationCreator.new(org)
      creator_one.seed!

      validate_org(org)

      creator_two = Katello::OrganizationCreator.new(org)
      creator_two.seed!

      validate_creator_equal(creator_one, creator_two)
      validate_org(org)
    end

    def test_seed_all_organizations
      org = FactoryBot.create(:organization)
      relation = ::Organization.where(id: org.id)
      ::Organization.expects(:not_created_in_katello).returns(relation)

      Katello::OrganizationCreator.seed_all_organizations!

      validate_org(org)
    end

    def test_create
      org = FactoryBot.build(:organization)
      creator = Katello::OrganizationCreator.new(org)

      Katello::Ping.expects(:ping!).returns(true)
      org.expects(:candlepin_owner_exists?).returns(false)
      Katello::Resources::Candlepin::Owner.expects(:create).with(org.name, org.name, content_access_mode: 'org_environment').returns(true)
      Katello::Resources::Candlepin::Owner.expects(:get_ueber_cert).returns(true)
      Katello::ContentViewEnvironment.any_instance.expects(:exists_in_candlepin?).returns(false)
      Katello::Resources::Candlepin::Environment.expects(:create).returns(true)

      creator.create!
      validate_org(org)
      validate_creator(creator)
    end

    def test_create_rollback
      org = FactoryBot.build(:organization, name: 'rollback_org')
      creator = Katello::OrganizationCreator.new(org)

      Katello::Ping.expects(:ping!).returns(true)
      org.expects(:candlepin_owner_exists?).returns(false)
      Katello::Resources::Candlepin::Owner.expects(:create).raises(Katello::Errors::CandlepinNotRunning)
      Katello::Resources::Candlepin::Environment.expects(:create).never

      assert_raises(Katello::Errors::CandlepinNotRunning) { creator.create! }

      refute ::Organization.find_by_name('rollback_org')
    end

    def test_create_existing
      org = FactoryBot.build(:organization)
      creator = Katello::OrganizationCreator.new(org)
      Katello::Ping.expects(:ping!).twice.returns(true)
      org.expects(:candlepin_owner_exists?).returns(false)
      Katello::Resources::Candlepin::Owner.expects(:create).once
      Katello::ContentViewEnvironment.any_instance.expects(:exists_in_candlepin?).returns(false)
      Katello::Resources::Candlepin::Environment.expects(:create).once
      Katello::Resources::Candlepin::Owner.expects(:get_ueber_cert).once
      creator.create!
      validate_creator(creator)

      creator_two = Katello::OrganizationCreator.new(org)

      org.expects(:candlepin_owner_exists?).returns(true)
      Katello::ContentViewEnvironment.any_instance.expects(:exists_in_candlepin?).returns(true)

      creator_two.create!
      validate_creator(creator_two)
      validate_creator_equal(creator, creator_two)
    end

    def test_create_raise_validation_errors
      org = FactoryBot.build(:organization)
      org.name = nil
      refute org.valid?

      creator = Katello::OrganizationCreator.new(org)
      creator.expects(:create_backend_objects!).returns

      assert_raises(ActiveRecord::RecordInvalid) do
        creator.create!
      end
    end

    def test_create_no_raise_validation_errors
      org = FactoryBot.build(:organization)
      org.name = nil
      refute org.valid?

      creator = Katello::OrganizationCreator.new(org)
      creator.expects(:create_backend_objects!).returns

      refute creator.create!(raise_validation_errors: false)
    end

    def test_create_all_organizations
      org = FactoryBot.create(:organization)
      relation = ::Organization.where(id: org.id)
      ::Organization.expects(:not_created_in_katello).returns(relation)
      Katello::Ping.expects(:ping!).returns(true)
      Katello::OrganizationCreator.any_instance.expects(:create!)

      Katello::OrganizationCreator.create_all_organizations!
    end

    def test_create_all_organizations_no_validation_errors
      org = FactoryBot.build(:organization)
      org.name = nil
      refute org.valid?

      ::Organization.expects(:not_created_in_katello).returns([org])
      Katello::Ping.expects(:ping!).returns(true)
      Katello::OrganizationCreator.any_instance.expects(:create_backend_objects!).returns

      Katello::OrganizationCreator.create_all_organizations!
    end

    def test_needs_candlepin_organization
      org = FactoryBot.create(:organization)
      org.stubs(:candlepin_owner_exists?).returns(false)

      creator = Katello::OrganizationCreator.new(org)
      creator.seed!

      assert creator.needs_candlepin_organization?
    end

    private

    def validate_org(organization)
      assert organization.library
      assert organization.redhat_provider
      assert organization.anonymous_provider

      library_view = organization.library.content_views.first
      library_version = library_view.versions.first
      assert_equal 1, library_version.major
      assert_equal 0, library_version.minor
      assert ::Katello::ContentViewEnvironment.where(content_view: library_view, content_view_version: library_version).exists?
    end

    def validate_creator(creator)
      assert creator.library_view
      assert creator.library_cvv
      assert creator.library_environment
      assert creator.content_view_environment
      assert creator.redhat_provider
      assert creator.anonymous_provider
    end

    def validate_creator_equal(one, two)
      assert_equal one.library_view, two.library_view
      assert_equal one.library_cvv, two.library_cvv
      assert_equal one.library_environment, two.library_environment
      assert_equal one.content_view_environment, two.content_view_environment
      assert_equal one.redhat_provider, two.redhat_provider
      assert_equal one.anonymous_provider, two.anonymous_provider
    end
  end
end
