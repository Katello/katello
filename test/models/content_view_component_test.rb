require 'katello_test_helper'

module Katello
  class ContentViewComponentTest < ActiveSupport::TestCase
    def setup
      @composite = ContentView.find(katello_content_views(:composite_view).id)
    end

    def test_create_with_no_cv_or_cvv
      component = ContentViewComponent.create(:composite_content_view => @composite)
      refute_with_error(component, /^Either set the content view with the latest flag or set the content view version/)
    end

    def test_create_with_composite_content_view
      view1 = create(:katello_content_view)
      assert ContentViewComponent.create(:composite_content_view => @composite,
                                         :content_view => view1, :latest => true)

      view2 = create(:katello_content_view)
      component = ContentViewComponent.create(:composite_content_view => view1,
                                              :content_view => view2, :latest => true)
      refute_with_error(component, /^Cannot associate a component to a non composite content view/)
    end

    def test_create_with_content_view_version_latest_good
      view1 = create(:katello_content_view)
      version1 = create(:katello_content_view_version, :content_view => view1)
      assert ContentViewComponent.create(:composite_content_view => @composite,
                                         :content_view_version => version1, :latest => false)
      @composite = @composite.reload
      assert_equal 1, @composite.content_view_components.size
      assert_equal version1, @composite.content_view_components.first.content_view_version
      assert_equal view1, @composite.content_view_components.first.content_view
      refute @composite.content_view_components.first.latest?
    end

    def test_create_with_content_view_version_latest_bad
      view1 = create(:katello_content_view)
      version1 = create(:katello_content_view_version, :content_view => view1)
      component = ContentViewComponent.create(:composite_content_view => @composite,
                                              :content_view_version => version1, :latest => true)

      refute_with_error(component, /^Either set the latest content view or the content view version. Cannot set both/)

      composite_view1 = create(:katello_content_view, :composite)
      composite_version1 = create(:katello_content_view_version, :content_view => composite_view1)
      component = ContentViewComponent.create(:composite_content_view => @composite,
                                              :content_view_version => composite_version1, :latest => false)
      refute_with_error(component, /^Cannot add composite versions to a composite content view/)

      default_view_version = katello_content_view_versions(:library_default_version)
      component = ContentViewComponent.create(:composite_content_view => @composite,
                                              :content_view_version => default_view_version, :latest => false)
      refute_with_error(component, /^Cannot add default content view to composite content view/)
    end

    def test_create_with_content_view_latest_good
      view1 = create(:katello_content_view)
      version1 = create(:katello_content_view_version, :content_view => view1)
      assert ContentViewComponent.create(:composite_content_view => @composite,
                                         :content_view => view1, :latest => true)
      @composite = @composite.reload
      assert_equal 1, @composite.content_view_components.size
      assert_nil @composite.content_view_components.first.content_view_version
      assert_equal view1, @composite.content_view_components.first.content_view
      assert @composite.content_view_components.first.latest?
      assert_equal version1, @composite.content_view_components.first.latest_version
    end

    def test_create_with_content_view_latest_bad
      view1 = create(:katello_content_view)
      _ = create(:katello_content_view_version, :content_view => view1)
      component = ContentViewComponent.create(:composite_content_view => @composite,
                                              :content_view => view1, :latest => false)
      refute_with_error(component, /^Content View Version not set/)

      composite_view1 = create(:katello_content_view, :composite)
      component = ContentViewComponent.create(:composite_content_view => @composite,
                                              :content_view => composite_view1, :latest => true)
      refute_with_error(component, /^Cannot add composite versions to a composite content view/)

      default_view = katello_content_views(:acme_default)
      component = ContentViewComponent.create(:composite_content_view => @composite,
                                         :content_view => default_view, :latest => true)
      refute_with_error(component, /^Cannot add default content view to composite content view/)
    end

    def test_create_content_view_with_multiple_components_good
      view1 = create(:katello_content_view)
      version1 = create(:katello_content_view_version, :content_view => view1)
      assert ContentViewComponent.create(:composite_content_view => @composite,
                                         :content_view => view1, :latest => true)

      view2 = create(:katello_content_view)
      version2 = create(:katello_content_view_version, :content_view => view2)
      assert ContentViewComponent.create(:composite_content_view => @composite,
                                         :content_view_version => version2, :latest => false)
      @composite = @composite.reload
      assert_equal 2, @composite.content_view_components.size
      assert_includes @composite.components, version1
      assert_includes @composite.components, version2
    end

    def test_create_content_view_with_duplicate_components
      view1 = create(:katello_content_view)
      version1 = create(:katello_content_view_version, :content_view => view1)
      ContentViewComponent.create!(:composite_content_view => @composite,
                                   :content_view => view1, :latest => true)
      @composite = @composite.reload
      component = ContentViewComponent.create(:composite_content_view => @composite,
                                              :content_view => view1, :latest => true)
      refute_with_error(component, /^Another component already includes content view with ID/)

      component = ContentViewComponent.create(:composite_content_view => @composite,
                                              :content_view_version => version1, :latest => false)
      refute_with_error(component,
                             /^Another component already includes content view with ID/)
    end

    def test_create_content_view_with_generate_cv_components
      view1 = create(:katello_content_view)
      view1.generated_for_repository_export!
      create(:katello_content_view_version, :content_view => view1)
      component = ContentViewComponent.create(:composite_content_view => @composite,
                                   :content_view => view1, :latest => true)
      refute_with_error(component, /^Cannot add generated content view versions to composite content view/)

      view1.generated_for_none!
      @composite = @composite.reload
      component = ContentViewComponent.create!(:composite_content_view => @composite,
                                              :content_view => view1, :latest => true)
      assert_valid component
    end

    def test_latest_versions
      # test that it gets the latest versions correctly
      view1 = create(:katello_content_view)
      version_max = create(:katello_content_view_version, :content_view => view1, :major => "12")
      create(:katello_content_view_version, :content_view => view1, :major => "2")
      create(:katello_content_view_version, :content_view => view1, :major => "2")

      ContentViewComponent.create!(:composite_content_view => @composite,
                                   :content_view => view1, :latest => true)
      @composite = @composite.reload
      assert_equal 1, @composite.components.size
      assert_equal version_max, @composite.components.first
    end

    def test_latest_versions_unpublished_content_view
      # now verify adding a content view with no versions (i.e. not published yet)
      # make composite component call ignore components from that cv
      view1 = create(:katello_content_view)
      ContentViewComponent.create!(:composite_content_view => @composite,
                                   :content_view => view1, :latest => true)
      @composite = @composite.reload
      assert_empty @composite.components
    end

    def test_update
      view1 = create(:katello_content_view)
      version1 = create(:katello_content_view_version, :content_view => view1)

      ContentViewComponent.create!(:composite_content_view => @composite,
                                   :content_view => view1, :latest => true)

      view2 = create(:katello_content_view)
      version2 = create(:katello_content_view_version, :content_view => view2)

      component = ContentViewComponent.create!(:composite_content_view => @composite,
                                               :content_view => view2, :latest => true)

      assert component.update(:latest => false, :content_view_version => version2)
      refute component.update(:latest => false, :content_view_version => version1)
      refute component.update(:latest => false)
    end

    def test_add_components
      view1 = create(:katello_content_view)
      version1 = create(:katello_content_view_version, :content_view => view1)

      view2 = create(:katello_content_view)
      version2 = create(:katello_content_view_version, :content_view => view2)

      @composite.add_components([{:content_view_id => view1.id, :latest => true},
                                 {:content_view_version_id => version2.id, :latest => false}])
      assert @composite.save
      @composite = @composite.reload
      assert_equal 2, @composite.content_view_components.size
      assert_includes @composite.components, version1
      assert_includes @composite.components, version2
    end

    def test_add_components_invalid
      view1 = create(:katello_content_view)
      version1 = create(:katello_content_view_version, :content_view => view1)
      @composite.add_components([{:content_view_id => view1.id, :latest => true},
                                 {:content_view_version_id => version1.id, :latest => true}])
      refute @composite.save
    end

    def test_remove_components
      view1 = create(:katello_content_view)
      create(:katello_content_view_version, :content_view => view1)

      view2 = create(:katello_content_view)
      version2 = create(:katello_content_view_version, :content_view => view2)

      @composite.add_components([{:content_view_id => view1.id, :latest => true},
                                 {:content_view_version_id => version2.id, :latest => false}])
      @composite.save!
      @composite.remove_components(@composite.content_view_components.pluck(:id))
      assert @composite.save

      assert_empty @composite.reload.content_view_components
    end

    def refute_with_error(component, error_message)
      refute component.valid?
      assert component.errors.full_messages.first =~ error_message
    end

    def test_needs_publish
      view1 = create(:katello_content_view)
      view2 = create(:katello_content_view)
      assert_equal @composite.needs_publish?, true
      @composite.create_new_version
      assert_equal @composite.reload.needs_publish?, false
      version1 = create(:katello_content_view_version, :content_view => view1)
      assert ContentViewComponent.create(:composite_content_view => @composite,
                                         :content_view_version => version1, :latest => false)
      assert_equal @composite.reload.needs_publish?, true
      @composite.create_new_version
      assert_equal @composite.reload.needs_publish?, false
      create(:katello_content_view_version, :content_view => view2)
      assert ContentViewComponent.create(:composite_content_view => @composite,
                                         :content_view => view2, :latest => true)
      assert_equal @composite.reload.needs_publish?, true
      @composite.create_new_version
      assert_equal @composite.reload.needs_publish?, false
      create(:katello_content_view_version, :content_view => view2, :major => "1000")
      assert_equal @composite.reload.needs_publish?, true
      @composite.create_new_version
      assert_equal @composite.reload.needs_publish?, false
    end
  end
end
