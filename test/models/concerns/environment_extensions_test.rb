# encoding: utf-8

require 'katello_test_helper'

module Katello
  class EnvironmentExtensionsTest < ActiveSupport::TestCase
    def setup
      User.current = User.find(users(:admin))
      @katello_id = "KT_Org_Env_View_1"

      @org = get_organization
      @org.label = @org.label.gsub(' ', '_')
      @env = KTEnvironment.find(katello_environments(:dev))
      @content_view = ContentView.find(katello_content_views(:library_dev_view))
    end

    def test_construct_katello_id
      id = Environment.construct_katello_id(@org, @env, @content_view)
      assert_equal id, [@org.label, @env.label, @content_view.label].join('/')
    end

    def test_construct_name
      name = Environment.construct_name(@org, @env, @content_view)
      assert_equal name, ["KT", @org.label, @env.label, @content_view.label, @content_view.id].join('_')
    end

    def test_build_by_katello_id
      env = Environment.build_by_katello_id(@org, @env, @content_view)
      refute_nil env
      env.save!
    end

    def test_find_by_katello_id
      assert_nil Environment.find_by_katello_id(@org, @env, @content_view)

      env = Environment.build_by_katello_id(@org, @env, @content_view)
      env.save!
      refute_nil Environment.find_by_katello_id(@org, @env, @content_view)
    end

    def test_find_or_create_by_katello_id
      assert_nil Environment.find_by_katello_id(@org, @env, @content_view)
      refute_nil Environment.find_or_build_by_katello_id(@org, @env, @content_view)
    end
  end
end
