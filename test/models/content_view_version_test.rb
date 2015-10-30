require 'katello_test_helper'

module Katello
  class ContentViewVersionTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin))
      @cvv = create(:katello_content_view_version, :major => 1, :minor => 0)
      @cvv_minor = create(:katello_content_view_version, :major => 1, :minor => 1)
      @cvv.organization.kt_environments << Katello::KTEnvironment.find_by_name(:Library)
      @dev = create(:katello_environment,  :organization => @cvv.organization, :prior => @cvv.organization.library,     :name => 'dev')
      @beta = create(:katello_environment, :organization => @cvv.organization, :prior => @dev,                         :name => 'beta')
      @composite_version = ContentViewVersion.find(katello_content_view_versions(:composite_view_version_1))
      @cvv_with_repo = ContentViewVersion.find(katello_content_view_versions(:library_view_version_1))
      @cvv_with_package_groups = ContentViewVersion.find(katello_content_view_versions(:library_default_version))
    end

    def test_promotable_in_sequence
      @cvv.expects(:environments).returns([@cvv.organization.library]).at_least_once
      assert @cvv.promotable?(@dev)
    end

    def test_promotable_out_of_sequence
      @cvv.expects(:environments).returns([@cvv.organization.library]).at_least_once
      refute @cvv.promotable?(@beta)
    end

    def test_promotable_without_environments
      @cvv.expects(:environments).returns([]).at_least_once
      assert @cvv.promotable?(@cvv.organization.library)
    end

    def test_promotable_without_environments2
      @cvv.expects(:environments).returns([]).at_least_once
      refute @cvv.promotable?(@dev)
    end

    def test_of_version
      version = @cvv
      assert_equal [version], version.content_view.versions.for_version("1.0")
      assert_equal [version], version.content_view.versions.for_version("1")
      assert_equal [version], version.content_view.versions.for_version(1)
      assert_equal [version], version.content_view.versions.for_version(1.0)
    end

    def test_next_incremental_version
      version = katello_content_view_versions(:composite_view_version_1)
      assert version.next_incremental_version, "1.1"

      version.minor = 5
      version.save!
      assert version.next_incremental_version, "1.6"
    end

    def test_docker_count
      cv = katello_content_views(:library_view)
      cvv = cv.versions.first
      assert cvv.repositories.archived.docker_type.count > 0
      image_count = 0
      tag_count = 0
      cvv.repositories.archived.docker_type.each do |repo|
        image = repo.docker_images.create!({:image_id => "abc123", :uuid => "123"},
                                             :without_protection => true
                                            )
        repo.docker_tags.create!(:name => "wat", :docker_image => image)
        image_count += repo.docker_images.count
        tag_count += repo.docker_tags.count
      end

      assert cvv.repositories.archived.docker_type.count > 0
      assert_equal image_count, cvv.docker_image_count
      assert_equal tag_count, cvv.docker_tag_count
    end

    def test_active_history_nil_task
      @cvv.history = [ContentViewHistory.new(:status => ContentViewHistory::IN_PROGRESS, :user => 'admin')]
      assert_empty @cvv.active_history
    end

    def test_find_package_groups
      assert @cvv_with_package_groups.package_groups.count > 0
    end

    def test_search_equal_version
      assert_includes ContentViewVersion.search_for("version = 1.0"), @cvv
      query = ContentViewVersion.search_for("version = 1")
      assert [@cvv, @cvv_minor] & query == [@cvv, @cvv_minor]
    end

    def test_search_compare_version
      assert_includes ContentViewVersion.search_for("version >= 1.0"), @cvv
      assert_includes ContentViewVersion.search_for("version <= 1.0"), @cvv
      assert_includes ContentViewVersion.search_for("version < 1.1"), @cvv
      assert_includes ContentViewVersion.search_for("version < 2"), @cvv
      assert_equal [], ContentViewVersion.search_for("version < 1")
      assert ContentViewVersion.search_for("version > 0").length > 1
      assert ContentViewVersion.search_for("version < 2").length > 1
    end

    def test_search_in_version
      assert_not_equal [@cvv], ContentViewVersion.search_for("version != 1.0")
      assert_includes ContentViewVersion.search_for("version ^ 1.0"), @cvv
      assert_not_equal [@cvv], ContentViewVersion.search_for("version ^! 1.0")
    end

    def test_search_content_view_id
      assert_equal [@cvv], ContentViewVersion.search_for("content_view_id = #{@cvv.content_view_id}")
    end

    def test_search_repository
      assert_includes ContentViewVersion.search_for("repository = busybox"), @cvv_with_repo
    end

    def test_components
      @composite_version.components = [@cvv]
      @composite_version.save!

      assert_equal [@cvv], @composite_version.reload.components
    end

    def test_component_default
      default_view = katello_content_view_versions(:library_default_version)
      assert_raises ActiveRecord::RecordInvalid do
        @composite_version.components = [default_view]
      end
    end

    def test_component_non_composite
      assert_raises ActiveRecord::RecordInvalid do
        @cvv.components = [@composite_version]
      end
    end

    def test_components_needing_errata
      errata = Erratum.find(katello_errata(:security))
      component = @composite_version.components.first
      assert_include @composite_version.components_needing_errata([errata]), component
    end

    def test_validate_destroyable!
      @cvv.composite_content_views = [@composite_version.content_view]
      @cvv.save!

      # checked on destroy
      assert_raises RuntimeError do
        @cvv.destroy
      end

      # checked when called direct
      assert_raises RuntimeError do
        @cvv.validate_destroyable!
      end

      @cvv.composite_content_views = []
      @cvv.save!

      # no failure when version not in composite
      assert_nothing_raised do
        @cvv.validate_destroyable!
      end
    end
  end
end
