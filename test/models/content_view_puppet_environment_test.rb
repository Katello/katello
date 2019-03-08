require 'katello_test_helper'

module Katello
  class ContentViewPuppetEnvironmentTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin).id)

      @library = FactoryBot.build(:katello_environment, :library => true)
      @content_view_version = FactoryBot.build(:katello_content_view_version)

      @puppet_env = FactoryBot.build(:katello_content_view_puppet_environment,
                                      :library_content_view_puppet_environment,
                                      :environment => @library,
                                      :content_view_version => @content_view_version)
    end

    def test_create
      assert @puppet_env.save
      refute_empty ContentViewPuppetEnvironment.where(:id => @puppet_env.id)
    end

    def test_content_type
      assert @puppet_env.save
      assert_equal "puppet", ContentViewPuppetEnvironment.find(@puppet_env.id).content_type
    end

    def test_in_content_view
      assert @puppet_env.save
      refute_empty ContentViewPuppetEnvironment.in_content_view(@content_view_version.content_view)

      library_dev_view = ContentView.find(katello_content_views(:library_dev_view).id)
      assert_empty ContentViewPuppetEnvironment.in_content_view(library_dev_view)
    end

    def test_in_environment
      assert @puppet_env.save
      refute_empty ContentViewPuppetEnvironment.in_environment(@library)

      dev = KTEnvironment.find(katello_environments(:staging).id)
      assert_empty ContentViewPuppetEnvironment.in_environment(dev)
    end

    def test_archive
      refute @puppet_env.archive?

      @puppet_env.environment = nil
      @puppet_env.save
      assert @puppet_env.archive?
    end

    def test_sets_pulp_id_on_save
      @puppet_env.pulp_id = nil
      @puppet_env.save!
      assert @puppet_env.pulp_id
    end

    def test_puppet_importer_values_for_mirror_on_sync
      assert @puppet_env.mirror_on_sync?
      capsule = FactoryBot.create(:smart_proxy, :default_smart_proxy)
      #= mock(:pulp3_support? => false, :pulp_mirror? => false)

      refute @puppet_env.nonpersisted_repository.generate_importer(capsule).remove_missing

      Cert::Certs.stubs(:ueber_cert).returns({})
      other_capsule = mock(:pulp3_support? => false, :pulp_mirror? => true)
      assert true, @puppet_env.nonpersisted_repository.generate_importer(other_capsule).remove_missing
    end
  end

  class ContentViewPuppetEnvironmentPulpIdTest < ActiveSupport::TestCase
    def test_set_pulp_id_cv_env
      SecureRandom.expects(:uuid).returns('SECURE_UUID')
      env = katello_content_view_puppet_environments(:dev_view_puppet_environment)
      env.pulp_id = nil
      env.set_pulp_id

      assert_equal "#{env.organization.id}-published_library_view-dev_label-puppet-SECURE_UUID", env.pulp_id
    end

    def test_set_pulp_id_cv_archive
      SecureRandom.expects(:uuid).returns('SECURE_UUID')
      env = katello_content_view_puppet_environments(:archive_view_puppet_environment)
      env.pulp_id = nil
      env.set_pulp_id

      assert_equal "#{env.organization.id}-published_library_view-v2_0-puppet-SECURE_UUID", env.pulp_id
    end

    def test_set_pulp_id_no_overwrite
      env = katello_content_view_puppet_environments(:dev_view_puppet_environment)
      id = env.pulp_id
      env.set_pulp_id

      assert_equal id, env.pulp_id
    end
  end
end
