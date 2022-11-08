require 'katello_test_helper'

module Katello
  class ContentViewVersionTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin).id)
      @cvv = create(:katello_content_view_version, :major => 1, :minor => 0)
      @cvv_minor = create(:katello_content_view_version, :major => 1, :minor => 1)
      @cvv_override = create(:katello_content_view_version, :major => 5, :minor => 2)
      @cvv.organization.kt_environments << Katello::KTEnvironment.find_by_name(:Library)
      @dev = create(:katello_environment,  :organization => @cvv.organization, :prior => @cvv.organization.library, :name => 'dev')
      @beta = create(:katello_environment, :organization => @cvv.organization, :prior => @dev, :name => 'beta')
      @composite_version = ContentViewVersion.find(katello_content_view_versions(:composite_view_version_1).id)
      @cvv_with_repo = ContentViewVersion.find(katello_content_view_versions(:library_view_version_1).id)
      @cvv_with_package_groups = ContentViewVersion.find(katello_content_view_versions(:library_default_version).id)
    end

    def test_description
      cvv_desc = ::Katello::ContentViewHistory.create!(:katello_content_view_version_id => @cvv.id,
                                            :status => 'successful',
                                            :user => User.first,
                                            :action => Katello::ContentViewHistory.actions[:publish],
                                            :notes => "Success description"
                                           )

      assert_equal 'Success description', @cvv.description
      cvv_desc.destroy!

      ::Katello::ContentViewHistory.create!(:katello_content_view_version_id => @cvv.id,
                                            :status => 'failed',
                                            :user => User.first,
                                            :action => Katello::ContentViewHistory.actions[:publish],
                                            :notes => "Failed description"
                                           )

      assert_equal 'Failed description', @cvv.description
    end

    def test_promotable_in_sequence
      @cvv.expects(:environments).returns([@cvv.organization.library]).at_least_once
      assert @cvv.promotable?(@dev)
    end

    def test_multiple_promotable_in_sequence
      @cvv.expects(:environments).returns([@cvv.organization.library]).at_least_once
      assert @cvv.promotable?([@beta, @dev])
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
      content_view = version.content_view
      content_view.versions << @cvv_minor

      assert_equal [version], version.content_view.versions.for_version("1.0")
      assert_equal [version], version.content_view.versions.for_version("1")
      assert_equal [version], version.content_view.versions.for_version(1)
      assert_equal [version], version.content_view.versions.for_version(1.0)
      assert_equal [@cvv_minor], version.content_view.versions.for_version(1.1)
    end

    def test_version_override
      version = @cvv
      content_view = version.content_view
      content_view.versions << @cvv_override

      assert_equal [version], version.content_view.versions.for_version("1.0")
      assert_equal [version], version.content_view.versions.for_version("1")
      assert_equal [version], version.content_view.versions.for_version(1)
      assert_equal [version], version.content_view.versions.for_version(1.0)
      assert_equal [@cvv_override], version.content_view.versions.for_version(5.2)
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
      manifest_count = 0
      tag_count = 0
      cvv.repositories.archived.docker_type.each do |repo|
        manifest = repo.docker_manifests.create!(:digest => "abc123", :pulp_id => "123-#{rand(9999)}")
        repo.docker_tags.create!(:name => "wat", :docker_taggable => manifest, :pulp_id => "123-#{rand(9999)}")
        manifest_count += repo.docker_manifests.count
        tag_count += repo.docker_tags.count
      end
      DockerMetaTag.import_meta_tags(cvv.repositories.archived.docker_type)

      # simulate another not-archived (env ID not nil) repo existing in the cvv.
      # this repo should not count towards the cvv docker_tag_count.
      archived_repo = cvv.repositories.archived.docker_type[0]
      dup_repo = archived_repo.dup
      dup_repo.save!
      dup_repo.update(:environment_id => ::Katello::KTEnvironment.find_by(:name => "Dev").id)
      dup_repo.docker_tags = [archived_repo.docker_tags[0]]
      ::Katello::DockerMetaTag.import_meta_tags([dup_repo])
      assert cvv.repositories.archived.docker_type.count > 0

      cvv.update_content_counts!
      counts = cvv.content_counts_map
      assert_equal manifest_count, counts["docker_manifest_count"]
      assert_equal tag_count, counts["docker_tag_count"]
    end

    def test_python_package_count
      SmartProxy.stubs(:pulp_primary).returns(SmartProxy.pulp_primary)
      cv = katello_content_views(:acme_default)
      cvv = cv.versions.first

      assert_includes Katello::RootRepository.where(id: cvv.repositories.pluck(:root_id)).pluck(:content_type).uniq, "python"

      #stub RepositoryTypeManager to return python
      Katello::RepositoryTypeManager.stubs(:indexable_content_types).returns(
        [Katello::RepositoryType::ContentType.new({model_class: Katello::GenericContentUnit, content_type: 'python_package'})]
      )

      cvv.update_content_counts!
      counts = cvv.content_counts_map

      assert_equal 0, counts["python_package_count"]
    end

    def test_active_history_nil_task
      @cvv.history = [ContentViewHistory.new(:status => ContentViewHistory::IN_PROGRESS, :user => 'admin', :action => 'publish')]
      assert_empty @cvv.active_history
    end

    def test_find_package_groups
      assert @cvv_with_package_groups.package_groups.count > 0
    end

    def test_search_equal_version
      assert_includes ContentViewVersion.search_for("version = 1.0"), @cvv
      query = ContentViewVersion.search_for("version = 1")
      assert_equal [@cvv, @cvv_minor] & query, [@cvv, @cvv_minor]
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
      errata = Erratum.find(katello_errata(:security).id)
      component = @composite_version.components.first
      assert_includes @composite_version.components_needing_errata([errata]), component
    end

    def test_with_organization_id
      assert_includes(Katello::ContentViewVersion.with_organization_id(@cvv.organization.id), @cvv)
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

      @cvv.composites << @composite_version
      assert_raises RuntimeError do
        @cvv.validate_destroyable!
      end

      @cvv.composites = []

      # no failure when version not in composite
      assert_nothing_raised do
        @cvv.validate_destroyable!
      end
    end
  end
end
