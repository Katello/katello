require 'katello_test_helper'

module Katello
  class ContentViewPuppetModuleTest < ActiveSupport::TestCase
    def setup
      User.current   = User.find(users(:admin).id)
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

    def test_computed_version
      content_view_puppet_module = ContentViewPuppetModule.new(
        :uuid => katello_puppet_modules(:foreman_proxy).uuid,
        :content_view => @library_view
      )
      assert_equal "1.0", content_view_puppet_module.computed_version
    end

    def test_computed_version_nil
      content_view_puppet_module = ContentViewPuppetModule.new(
        :uuid => nil,
        :content_view => @library_view
      )
      assert_equal nil, content_view_puppet_module.computed_version
    end

    def test_latest_in_modules_by_author
      repo = katello_repositories(:p_forge)
      puppet_module_apt = katello_puppet_modules(:test_apt3)
      content_view_puppet_module = ContentViewPuppetModule.new(
        :uuid => puppet_module_apt.uuid,
        :author => puppet_module_apt.author,
        :content_view => @library_view
      )
      content_view_puppet_module.save!
      repo.puppet_modules = [katello_puppet_modules(:test_apt1),
                             katello_puppet_modules(:test_apt2),
                             katello_puppet_modules(:test_apt3)]
      modules = PuppetModule.in_repositories(repo)
      modules = modules.where(:name => puppet_module_apt.name)
      assert_equal true, content_view_puppet_module.latest_in_modules_by_author?(modules)
    end
  end
end
