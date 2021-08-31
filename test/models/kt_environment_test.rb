# encoding: utf-8

require 'katello_test_helper'

module Katello
  class KTEnvironmentTestBase < ActiveSupport::TestCase
    extend ActiveRecord::TestFixtures

    def setup
      @acme_corporation = get_organization

      @library              = KTEnvironment.find(katello_environments(:library).id)
      @dev                  = KTEnvironment.find(katello_environments(:dev).id)
      @staging              = KTEnvironment.find(katello_environments(:staging).id)
    end
  end

  class KTEnvironmentTest < KTEnvironmentTestBase
    should allow_values(*valid_name_list).for(:name)
    should_not allow_values(*invalid_name_list).for(:name)
    should allow_value(RFauxFactory.gen_utf8).for(:description)

    def test_create_and_validate_default_content_view
      env = KTEnvironment.create(:organization => @acme_corporation, :name => "SomeEnv", :prior => @library)
      assert_nil env.default_content_view
      assert_nil env.default_content_view_version
    end

    def test_destroy_env_with_systems_should_fail
      env = KTEnvironment.create!(:name => "batman", :organization => @acme_corporation, :prior => @library)
      env.expects(:content_facets).returns([stub])
      assert_raises(RuntimeError) do
        env.destroy!
      end
    end

    def test_destroy_env_with_activation_keys_should_fail
      env = KTEnvironment.create!(:name => "batman", :organization => @acme_corporation, :prior => @library)
      env.stubs(:activation_keys).returns([stub])
      assert_raises(RuntimeError) do
        env.destroy!
      end
    end

    def test_destroy_middle
      env = katello_environments(:qa_path1)
      prior = env.prior
      successor = env.successor

      assert env.deletable?
      env.destroy!
      successor.reload

      assert_equal prior, successor.prior
      assert_includes prior.successors, successor
    end

    def test_destroy_library
      User.current = User.find(users(:admin).id)
      org = taxonomies(:empty_organization)

      org.library.destroy

      refute org.library.destroyed?
    end

    def test_products_are_unique
      provider = create(:katello_provider, organization: @acme_corporation)
      product = create(:katello_product, provider: provider, organization: @acme_corporation)
      2.times do
        create(:katello_repository, product: product, environment: @library,
               content_view_version: @library.default_content_view_version)
      end

      refute_empty @library.products
      assert_equal @library.products.uniq.sort, @library.products.sort
      assert_operator @library.repositories.map(&:product).length, :>, @library.products.length
    end

    def test_content_view_label_excludes_library
      env = @acme_corporation.kt_environments.build(:name => "Test", :label => "Library",
                                                    :prior => @library)
      refute env.save
      assert_equal 1, env.errors.size
      # this an ActiveModel::Errors object; not a Hash
      assert_includes env.errors, :label
    end

    def test_content_view_label_excludes_content_dir
      env = @acme_corporation.kt_environments.build(:name => "Test", :label => ContentView::CONTENT_DIR,
                                                    :prior => @library)
      refute env.save
      assert_equal 1, env.errors.size
      # this an ActiveModel::Errors object; not a Hash
      assert_includes env.errors, :label
    end

    def test_audit_on_env_creation
      env = nil
      assert_difference 'Audit.count', 2 do
        env = KTEnvironment.create(
          :organization => @acme_corporation,
          :name => "AuditEnv", :prior => @library)
      end
      recent_audit = env.audits.last
      assert_equal 'create', recent_audit.action
    end

    def test_audit_on_env_destroy
      env = KTEnvironment.create(:organization => @acme_corporation,
        :name => "AuditEnv", :prior => @library)
      env.destroy
      assert Audit.find_by(auditable_type: 'Katello::KTEnvironment', action: 'destroy', auditable_id: env.id)
    end

    def test_insert_successor_after_library
      @library.insert_successor({ :organization => @acme_corporation, :name => "testEnv" }, @dev.path)
      assert_includes @library.successors.map(&:name), "testEnv"
      assert_equal "testEnv", @dev.prior.name
    end

    def test_insert_successor_to_the_end
      succ = @staging.insert_successor({ :organization => @acme_corporation, :name => "testEnv" }, @staging.path)
      assert_equal succ.prior, @staging
    end

    def test_insert_successor_in_the_middle
      succ = @dev.insert_successor({ :organization => @acme_corporation, :name => "testEnv" }, @dev.path)
      assert_equal succ.prior, @dev
    end
  end
end
