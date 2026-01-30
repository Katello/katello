require 'katello_test_helper'

module Actions::Katello::ContentViewVersion
  class IncrementalUpdateTest < ActiveSupport::TestCase
    include Dynflow::Testing
    include Support::Actions::Fixtures
    include FactoryBot::Syntax::Methods

    before :all do
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

        # Stub repositories to avoid the content comparison logic in run
        component_version.stubs(:repositories).returns([])

        # Stub find for old_version (will be nil in most tests, stub to return a version with empty repos)
        old_version_stub = stub('old_version', repositories: [])
        ::Katello::ContentViewVersion.stubs(:find).with(nil).returns(old_version_stub)
      end

      it 'excludes propagated composites from auto-publish list' do
        # Set input as if plan_self was called with propagated composite IDs
        action.input.update(
          new_content_view_version_id: component_version.id,
          propagated_composite_cv_ids: [composite_cv.id]
        )

        # Stub ContentViewVersion.find to return our version
        ::Katello::ContentViewVersion.stubs(:find).with(component_version.id).returns(component_version)

        # Stub to make the version appear latest and non-composite
        component_version.stubs(:latest?).returns(true)
        component_cv.stubs(:composite?).returns(false)

        # Mock auto_publish_composites to return our composite
        mock_relation = mock('auto_publish_composites')
        mock_relation.expects(:pluck).with(:id).returns([composite_cv.id])
        component_cv.stubs(:auto_publish_composites).returns(mock_relation)

        # Run the action
        action.run

        # The composite should be excluded from auto-publish because it's in propagated list
        auto_publish_ids = mock_output[:auto_publish_content_view_ids]
        assert_equal [], auto_publish_ids,
                    "Expected auto_publish_content_view_ids to be empty when composite is propagated"
      end

      it 'includes composites in auto-publish list when not propagated' do
        # Set input without propagated composites
        action.input.update(
          new_content_view_version_id: component_version.id,
          propagated_composite_cv_ids: []
        )

        ::Katello::ContentViewVersion.stubs(:find).with(component_version.id).returns(component_version)
        component_version.stubs(:latest?).returns(true)
        component_cv.stubs(:composite?).returns(false)

        mock_relation = mock('auto_publish_composites')
        mock_relation.expects(:pluck).with(:id).returns([composite_cv.id])
        component_cv.stubs(:auto_publish_composites).returns(mock_relation)

        action.run

        # The composite should be included since it's not propagated
        auto_publish_ids = mock_output[:auto_publish_content_view_ids]
        assert_equal [composite_cv.id], auto_publish_ids,
                    "Expected composite to be in auto-publish list when not propagated"
      end

      it 'handles partial propagation with multiple composites' do
        # Create a second composite ID (simulated)
        composite_cv2_id = composite_cv.id + 100

        action.input.update(
          new_content_view_version_id: component_version.id,
          propagated_composite_cv_ids: [composite_cv.id]  # Only first is propagated
        )

        ::Katello::ContentViewVersion.stubs(:find).with(component_version.id).returns(component_version)
        component_version.stubs(:latest?).returns(true)
        component_cv.stubs(:composite?).returns(false)

        # Mock returns both composites
        mock_relation = mock('auto_publish_composites')
        mock_relation.expects(:pluck).with(:id).returns([composite_cv.id, composite_cv2_id])
        component_cv.stubs(:auto_publish_composites).returns(mock_relation)

        action.run

        auto_publish_ids = mock_output[:auto_publish_content_view_ids]

        # First composite should be excluded (propagated)
        refute_includes auto_publish_ids, composite_cv.id,
                        "Propagated composite should be excluded"

        # Second composite should be included (not propagated)
        assert_includes auto_publish_ids, composite_cv2_id,
                        "Non-propagated composite should be included"
        assert_equal [composite_cv2_id], auto_publish_ids,
                    "Only non-propagated composite should be in list"
      end

      it 'handles nil propagated_composite_cv_ids for backward compatibility' do
        # Don't set propagated_composite_cv_ids at all (backward compatibility)
        action.input.update(
          new_content_view_version_id: component_version.id
        )

        ::Katello::ContentViewVersion.stubs(:find).with(component_version.id).returns(component_version)
        component_version.stubs(:latest?).returns(true)
        component_cv.stubs(:composite?).returns(false)

        mock_relation = mock('auto_publish_composites')
        mock_relation.expects(:pluck).with(:id).returns([composite_cv.id])
        component_cv.stubs(:auto_publish_composites).returns(mock_relation)

        action.run

        # Should work with empty array default
        auto_publish_ids = mock_output[:auto_publish_content_view_ids]
        assert_equal [composite_cv.id], auto_publish_ids,
                    "Should include composite when propagated_composite_cv_ids is nil"
      end

      it 'does not auto-publish for composite content views' do
        # Composite CVs should not trigger auto-publish at all
        composite_version = composite_cv.versions.first

        action.input.update(
          new_content_view_version_id: composite_version.id,
          propagated_composite_cv_ids: []
        )

        ::Katello::ContentViewVersion.stubs(:find).with(composite_version.id).returns(composite_version)
        composite_version.stubs(:latest?).returns(true)
        composite_version.stubs(:repositories).returns([])
        composite_cv.stubs(:composite?).returns(true)

        action.run

        # Composite CVs don't set auto_publish_content_view_ids
        assert_nil mock_output[:auto_publish_content_view_ids],
              "Composite CVs should not set auto_publish_content_view_ids"
      end

      it 'does not auto-publish for non-latest versions' do
        # Non-latest versions should not trigger auto-publish
        action.input.update(
          new_content_view_version_id: component_version.id,
          propagated_composite_cv_ids: []
        )

        ::Katello::ContentViewVersion.stubs(:find).with(component_version.id).returns(component_version)
        component_version.stubs(:latest?).returns(false)
        component_cv.stubs(:composite?).returns(false)

        action.run

        # Non-latest versions don't set auto_publish_content_view_ids
        assert_nil mock_output[:auto_publish_content_view_ids],
              "Non-latest versions should not set auto_publish_content_view_ids"
      end
    end
  end
end
