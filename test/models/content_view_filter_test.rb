require 'katello_test_helper'

module Katello
  class ContentViewFilterTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin).id)
      @repo = Repository.find(katello_repositories(:fedora_17_x86_64).id)
      @view = create(:katello_content_view, :organization => @repo.product.organization)
      @filter = create(:katello_content_view_filter, :content_view => @view)
      ContentView.any_instance.stubs(:reindex_on_association_change).returns(true)
    end

    def test_create
      assert @filter.save
    end

    def test_original_module_streams
      filter = FactoryBot.create(:katello_content_view_module_stream_filter, :content_view => @view)
      filter.update(original_module_streams: true)
      @repo.expects(:module_streams_without_errata).returns([])
      filter.generate_clauses(@repo)
    end

    def test_composite_view
      skip "skip until composite content views are supported"
      # filter should not get created for a composite content view
      content_view = FactoryBot.create(:katello_content_view, :composite)
      filter = FactoryBot.build(:katello_content_view_filter, :content_view_id => content_view.id)
      assert_nil ContentViewFilter.find_by_id(filter.id)
      refute ContentViewFilter.exists?(filter.id)
    end

    def test_bad_name
      filter = FactoryBot.build(:katello_content_view_filter, :name => "")
      assert filter.invalid?
      assert_includes filter.errors, :name
    end

    def test_duplicate_name
      @filter.save!
      attrs = FactoryBot.attributes_for(:katello_content_view_filter,
                                         :name => @filter.name,
                                         :content_view_id => @filter.content_view_id)
      assert_raises(ActiveRecord::RecordInvalid) do
        ContentViewFilter.create!(attrs)
      end
      filter_item = ContentViewFilter.create(attrs)
      refute filter_item.persisted?
      refute filter_item.save
    end

    def test_search_name
      assert_equal @filter, ContentViewFilter.search_for("name = #{@filter.name}").first
    end

    test_attributes :pid => '1c9058f1-35c4-46f2-9b21-155ef988564a'
    def test_search_type
      assert_equal ContentViewPackageFilter, ContentViewFilter.search_for("content_type = rpm").first.class
    end

    test_attributes :pid => '6a86060f-6b4f-4688-8ea9-c198e0aeb3f6'
    def test_search_type_erratum
      assert_equal ContentViewErratumFilter, ContentViewFilter.search_for("content_type = erratum").first.class
    end

    test_attributes :pid => '832c50cc-c2c8-48c9-9a23-80956baf5f3c'
    def test_search_type_package_group
      assert_equal ContentViewPackageGroupFilter, ContentViewFilter.search_for("content_type = package_group").first.class
    end

    def test_search_inclusion
      inclusion = @filter.inclusion ? 'include' : 'exclude'
      assert_includes ContentViewFilter.search_for("inclusion_type = #{inclusion}"), @filter
    end

    def test_search_exclusion
      inclusion = @filter.inclusion ? 'exclude' : 'include'
      refute_includes ContentViewFilter.search_for("inclusion_type = #{inclusion}"), @filter
    end

    def test_add_bad_repo
      @filter.repositories << @repo
      assert_raises(ActiveRecord::RecordInvalid) do
        @filter.save!
      end
    end

    def test_add_good_repo
      view = @filter.content_view
      view.repositories << @repo
      view.save!
      @filter.repositories << @repo
      assert @filter.save
      refute_empty ContentViewFilter.find(@filter.id).repositories
    end

    def test_content_view_delete_repo
      @filter.save!
      view = @filter.content_view
      view.repositories << @repo
      view.save!
      @repo = Repository.find(@repo.id)
      @filter = ContentViewFilter.find(@filter.id)
      refute_empty @filter.content_view.repositories
      @repo = Repository.find(@repo.id)
      @filter.repositories << @repo
      @filter.save!
      view = ContentView.find(view.id)
      view.repositories.delete(@repo)
      view.save!
      assert_empty view.filters.first.repositories
    end
  end
end
