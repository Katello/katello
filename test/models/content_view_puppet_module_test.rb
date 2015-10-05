require 'katello_test_helper'

module Katello
  class ContentViewPuppetModuleTest < ActiveSupport::TestCase
    def setup
      User.current   = User.find(users(:admin))
      @library_view  = ContentView.find(katello_content_views(:library_view).id)
      @puppet_module = ContentViewPuppetModule.find(katello_content_view_puppet_modules(:library_view_abrt_module).id)
    end

    def test_create_with_name_author
      assert ContentViewPuppetModule.create!(:name => 'dhcp', :author => 'johndoe', :content_view => @library_view)
    end

    def test_create_with_name
      assert_raises ActiveRecord::RecordInvalid do
        ContentViewPuppetModule.create!(:name => 'dhcp', :content_view => @library_view)
      end
    end

    def test_create_with_uuid
      content_view_puppet_module = ContentViewPuppetModule.new(
        :uuid => katello_puppet_modules(:foreman_proxy).uuid,
        :content_view => @library_view
      )
      assert content_view_puppet_module.save!
    end

    def test_search_name
      assert_equal @puppet_module, ContentViewPuppetModule.search_for("name = \"#{@puppet_module.name}\"").first
    end

    def test_search_content_view_name
      assert_includes ContentViewPuppetModule.search_for("content_view_name = \"#{@library_view.name}\""), @puppet_module
    end

    def test_search_uuid
      @puppet_module = ContentViewPuppetModule.find(katello_content_view_puppet_modules(:library_view_module_by_uuid).id)
      assert_includes ContentViewPuppetModule.search_for("uuid = \"#{@puppet_module.uuid}\""), @puppet_module
    end

    def test_search_author
      assert_includes ContentViewPuppetModule.search_for("author = \"#{@puppet_module.author}\""), @puppet_module
    end
  end
end
