require 'katello_test_helper'

module Actions::Katello::ContentViewVersion
  class IncrementalUpdateAutoPropagateTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    before do
      User.current = users(:admin)
    end

    let(:action_class) { ::Actions::Katello::ContentViewVersion::IncrementalUpdate }
    let(:action) { create_action action_class }

    describe 'Auto Publish with Propagate' do
      let(:component_cv) { katello_content_views(:library_dev_view) }
      let(:component_version) { component_cv.versions.first }
      let(:composite_cv) { katello_content_views(:composite_view) }
      let(:mock_output) { {} }

      before do
        # Set up composite to have auto_publish enabled
        composite_cv.update!(auto_publish: true)

        # Ensure component has the composite in its relationships
        unless component_version.composites.include?(composite_cv.versions.first)
          ::Katello::ContentViewComponent.create!(
            composite_content_view: composite_cv,
            content_view: component_cv,
            latest: true
          )
        end

        # Stub the output to be writable
        action.stubs(:output).returns(mock_output)
      end

      it 'excludes propagated composites from auto-publish list' do
        # Set input as if plan_self was called with propagated composite IDs
        action.input.update(
          new_content_view_version_id: component_version.id,
          old_version: component_version.id,
          propagated_composite_cv_ids: [composite_cv.id]
        )

        ::Katello::ContentViewVersion.stubs(:find).with(component_version.id).returns(component_version)
        component_version.stubs(:repositories).returns([])
        component_version.stubs(:latest?).returns(true)
        component_cv.stubs(:composite?).returns(false)
        mock_relation = mock('auto_publish_composites')
        mock_relation.expects(:pluck).with(:id).returns([composite_cv.id])
        component_cv.stubs(:auto_publish_composites).returns(mock_relation)

        action.run
        assert_nil mock_output[:auto_publish_content_view_ids], "Expected auto_publish_content_view_ids to be nil when all composites are propagated"
        assert_nil mock_output[:auto_publish_content_view_version_id]
      end

      it 'includes composites in auto-publish list when not propagated' do
        # Set input without propagated composites
        action.input.update(
          new_content_view_version_id: component_version.id,
          old_version: component_version.id,
          propagated_composite_cv_ids: []
        )

        ::Katello::ContentViewVersion.stubs(:find).with(component_version.id).returns(component_version)
        component_version.stubs(:repositories).returns([])
        component_version.stubs(:latest?).returns(true)
        component_cv.stubs(:composite?).returns(false)
        mock_relation = mock('auto_publish_composites')
        mock_relation.expects(:pluck).with(:id).returns([composite_cv.id])
        component_cv.stubs(:auto_publish_composites).returns(mock_relation)

        action.run
        auto_publish_ids = mock_output[:auto_publish_content_view_ids]
        assert_equal [composite_cv.id], auto_publish_ids, "Expected composite to be in auto-publish list when not propagated"
        assert_equal component_version.id, mock_output[:auto_publish_content_view_version_id]
      end

      it 'handles partial propagation with multiple composites' do
        composite_cv2 = create(:katello_content_view, :composite,
                              organization: composite_cv.organization,
                              auto_publish: true)
        ::Katello::ContentViewComponent.create!(
          composite_content_view: composite_cv2,
          content_view: component_cv,
          latest: true
        )

        action.input.update(
          new_content_view_version_id: component_version.id,
          old_version: component_version.id,
          propagated_composite_cv_ids: [composite_cv.id] # Only first is propagated
        )

        ::Katello::ContentViewVersion.stubs(:find).with(component_version.id).returns(component_version)
        component_version.stubs(:repositories).returns([])
        component_version.stubs(:latest?).returns(true)
        component_cv.stubs(:composite?).returns(false)
        mock_relation = mock('auto_publish_composites')
        mock_relation.expects(:pluck).with(:id).returns([composite_cv.id, composite_cv2.id])
        component_cv.stubs(:auto_publish_composites).returns(mock_relation)

        action.run
        auto_publish_ids = mock_output[:auto_publish_content_view_ids]

        refute_includes auto_publish_ids, composite_cv.id, "Propagated composite should be excluded"
        assert_includes auto_publish_ids, composite_cv2.id, "Non-propagated composite should be included"
        assert_equal [composite_cv2.id], auto_publish_ids, "Only non-propagated composite should be in list"
        assert_equal component_version.id, mock_output[:auto_publish_content_view_version_id]
      end

      it 'handles nil propagated_composite_cv_ids for backward compatibility' do
        # Don't set propagated_composite_cv_ids at all (backward compatibility)
        action.input.update(
          new_content_view_version_id: component_version.id,
          old_version: component_version.id
        )

        ::Katello::ContentViewVersion.stubs(:find).with(component_version.id).returns(component_version)
        component_version.stubs(:repositories).returns([])
        component_version.stubs(:latest?).returns(true)
        component_cv.stubs(:composite?).returns(false)

        mock_relation = mock('auto_publish_composites')
        mock_relation.expects(:pluck).with(:id).returns([composite_cv.id])
        component_cv.stubs(:auto_publish_composites).returns(mock_relation)

        action.run
        auto_publish_ids = mock_output[:auto_publish_content_view_ids]
        assert_equal [composite_cv.id], auto_publish_ids, "Should include composite when propagated_composite_cv_ids is nil"
        assert_equal component_version.id, mock_output[:auto_publish_content_view_version_id]
      end

      it 'does not auto-publish for composite content views' do
        composite_version = composite_cv.versions.first

        action.input.update(
          new_content_view_version_id: composite_version.id,
          old_version: composite_version.id,
          propagated_composite_cv_ids: []
        )

        ::Katello::ContentViewVersion.stubs(:find).with(composite_version.id).returns(composite_version)
        composite_version.stubs(:latest?).returns(true)
        composite_version.stubs(:repositories).returns([])
        composite_cv.stubs(:composite?).returns(true)

        action.run
        assert_nil mock_output[:auto_publish_content_view_ids], "Composite CVs should not set auto_publish_content_view_ids"
        assert_nil mock_output[:auto_publish_content_view_version_id]
      end

      it 'does not auto-publish for non-latest versions' do
        action.input.update(
          new_content_view_version_id: component_version.id,
          old_version: component_version.id,
          propagated_composite_cv_ids: []
        )

        ::Katello::ContentViewVersion.stubs(:find).with(component_version.id).returns(component_version)
        component_version.stubs(:repositories).returns([])
        component_version.stubs(:latest?).returns(false)
        component_cv.stubs(:composite?).returns(false)

        action.run
        assert_nil mock_output[:auto_publish_content_view_ids], "Non-latest versions should not set auto_publish_content_view_ids"
        assert_nil mock_output[:auto_publish_content_view_version_id]
      end
    end

    describe 'Content Validation' do
      let(:cv) { katello_content_views(:library_dev_view) }
      let(:old_version) { cv.versions.first }
      let(:environments) { [katello_environments(:library)] }

      it 'returns early when no content is specified' do
        content = { package_ids: [], errata_ids: [], deb_ids: [] }

        # Should not query the database or raise an error
        ::Katello::RepositoryRpm.expects(:where).never
        ::Katello::RepositoryErratum.expects(:where).never
        ::Katello::RepositoryDeb.expects(:where).never

        action.send(:validate_content_not_already_present, old_version, content)
      end

      it 'fails when all RPM packages are already present in the version' do
        content = { package_ids: [1, 2, 3], errata_ids: [], deb_ids: [] }

        mock_repos = mock('repos')
        mock_repos.stubs(:pluck).with(:id).returns([10, 20])
        old_version.stubs(:repositories).returns(mock_repos)

        mock_relation = mock('relation')
        mock_distinct = mock('distinct')
        mock_distinct.stubs(:count).with(:rpm_id).returns(3)
        mock_relation.stubs(:distinct).returns(mock_distinct)
        ::Katello::RepositoryRpm.expects(:where)
          .with(repository_id: [10, 20], rpm_id: [1, 2, 3])
          .returns(mock_relation)

        error = assert_raises(RuntimeError) do
          action.send(:validate_content_not_already_present, old_version, content)
        end

        assert_match(/will not add any new content/, error.message)
      end

      it 'succeeds when some RPM packages are new' do
        content = { package_ids: [1, 2, 3], errata_ids: [], deb_ids: [] }

        mock_repos = mock('repos')
        mock_repos.stubs(:pluck).with(:id).returns([10, 20])
        old_version.stubs(:repositories).returns(mock_repos)

        mock_relation = mock('relation')
        mock_distinct = mock('distinct')
        mock_distinct.stubs(:count).with(:rpm_id).returns(2)
        mock_relation.stubs(:distinct).returns(mock_distinct)
        ::Katello::RepositoryRpm.expects(:where)
          .with(repository_id: [10, 20], rpm_id: [1, 2, 3])
          .returns(mock_relation)

        # Should not raise an error
        action.send(:validate_content_not_already_present, old_version, content)
      end

      it 'fails when all errata are already present in the version' do
        content = { package_ids: [], errata_ids: [5, 6], deb_ids: [] }

        mock_repos = mock('repos')
        mock_repos.stubs(:pluck).with(:id).returns([10, 20])
        old_version.stubs(:repositories).returns(mock_repos)

        mock_relation = mock('relation')
        mock_distinct = mock('distinct')
        mock_distinct.stubs(:count).with(:erratum_id).returns(2)
        mock_relation.stubs(:distinct).returns(mock_distinct)
        ::Katello::RepositoryErratum.expects(:where)
          .with(repository_id: [10, 20], erratum_id: [5, 6])
          .returns(mock_relation)

        error = assert_raises(RuntimeError) do
          action.send(:validate_content_not_already_present, old_version, content)
        end

        assert_match(/will not add any new content/, error.message)
      end

      it 'succeeds when some errata are new' do
        content = { package_ids: [], errata_ids: [5, 6], deb_ids: [] }

        mock_repos = mock('repos')
        mock_repos.stubs(:pluck).with(:id).returns([10, 20])
        old_version.stubs(:repositories).returns(mock_repos)

        mock_relation = mock('relation')
        mock_distinct = mock('distinct')
        mock_distinct.stubs(:count).with(:erratum_id).returns(1)
        mock_relation.stubs(:distinct).returns(mock_distinct)
        ::Katello::RepositoryErratum.expects(:where)
          .with(repository_id: [10, 20], erratum_id: [5, 6])
          .returns(mock_relation)

        # Should not raise an error
        action.send(:validate_content_not_already_present, old_version, content)
      end

      it 'fails when all deb packages are already present in the version' do
        content = { package_ids: [], errata_ids: [], deb_ids: [7, 8, 9] }

        mock_repos = mock('repos')
        mock_repos.stubs(:pluck).with(:id).returns([10, 20])
        old_version.stubs(:repositories).returns(mock_repos)

        mock_relation = mock('relation')
        mock_distinct = mock('distinct')
        mock_distinct.stubs(:count).with(:deb_id).returns(3)
        mock_relation.stubs(:distinct).returns(mock_distinct)
        ::Katello::RepositoryDeb.expects(:where)
          .with(repository_id: [10, 20], deb_id: [7, 8, 9])
          .returns(mock_relation)

        error = assert_raises(RuntimeError) do
          action.send(:validate_content_not_already_present, old_version, content)
        end

        assert_match(/will not add any new content/, error.message)
      end

      it 'succeeds when some deb packages are new' do
        content = { package_ids: [], errata_ids: [], deb_ids: [7, 8, 9] }

        mock_repos = mock('repos')
        mock_repos.stubs(:pluck).with(:id).returns([10, 20])
        old_version.stubs(:repositories).returns(mock_repos)

        mock_relation = mock('relation')
        mock_distinct = mock('distinct')
        mock_distinct.stubs(:count).with(:deb_id).returns(2)
        mock_relation.stubs(:distinct).returns(mock_distinct)
        ::Katello::RepositoryDeb.expects(:where)
          .with(repository_id: [10, 20], deb_id: [7, 8, 9])
          .returns(mock_relation)

        # Should not raise an error
        action.send(:validate_content_not_already_present, old_version, content)
      end

      it 'succeeds when mixed content has some new items' do
        content = { package_ids: [1, 2], errata_ids: [5, 6], deb_ids: [] }

        mock_repos = mock('repos')
        mock_repos.stubs(:pluck).with(:id).returns([10, 20])
        old_version.stubs(:repositories).returns(mock_repos)

        # RPMs: both already present
        mock_rpm_relation = mock('rpm_relation')
        mock_rpm_distinct = mock('rpm_distinct')
        mock_rpm_distinct.stubs(:count).with(:rpm_id).returns(2)
        mock_rpm_relation.stubs(:distinct).returns(mock_rpm_distinct)
        ::Katello::RepositoryRpm.expects(:where)
          .with(repository_id: [10, 20], rpm_id: [1, 2])
          .returns(mock_rpm_relation)

        # Errata: only 1 present, 1 is new
        mock_erratum_relation = mock('erratum_relation')
        mock_erratum_distinct = mock('erratum_distinct')
        mock_erratum_distinct.stubs(:count).with(:erratum_id).returns(1)
        mock_erratum_relation.stubs(:distinct).returns(mock_erratum_distinct)
        ::Katello::RepositoryErratum.expects(:where)
          .with(repository_id: [10, 20], erratum_id: [5, 6])
          .returns(mock_erratum_relation)

        # Should not raise an error because errata has new content
        action.send(:validate_content_not_already_present, old_version, content)
      end

      it 'fails when all mixed content types are already present' do
        content = { package_ids: [1, 2], errata_ids: [5, 6], deb_ids: [7] }

        mock_repos = mock('repos')
        mock_repos.stubs(:pluck).with(:id).returns([10, 20])
        old_version.stubs(:repositories).returns(mock_repos)

        # All RPMs present
        mock_rpm_relation = mock('rpm_relation')
        mock_rpm_distinct = mock('rpm_distinct')
        mock_rpm_distinct.stubs(:count).with(:rpm_id).returns(2)
        mock_rpm_relation.stubs(:distinct).returns(mock_rpm_distinct)
        ::Katello::RepositoryRpm.expects(:where)
          .with(repository_id: [10, 20], rpm_id: [1, 2])
          .returns(mock_rpm_relation)

        # All errata present
        mock_erratum_relation = mock('erratum_relation')
        mock_erratum_distinct = mock('erratum_distinct')
        mock_erratum_distinct.stubs(:count).with(:erratum_id).returns(2)
        mock_erratum_relation.stubs(:distinct).returns(mock_erratum_distinct)
        ::Katello::RepositoryErratum.expects(:where)
          .with(repository_id: [10, 20], erratum_id: [5, 6])
          .returns(mock_erratum_relation)

        # All debs present
        mock_deb_relation = mock('deb_relation')
        mock_deb_distinct = mock('deb_distinct')
        mock_deb_distinct.stubs(:count).with(:deb_id).returns(1)
        mock_deb_relation.stubs(:distinct).returns(mock_deb_distinct)
        ::Katello::RepositoryDeb.expects(:where)
          .with(repository_id: [10, 20], deb_id: [7])
          .returns(mock_deb_relation)

        error = assert_raises(RuntimeError) do
          action.send(:validate_content_not_already_present, old_version, content)
        end

        assert_match(/will not add any new content/, error.message)
      end
    end
  end
end
