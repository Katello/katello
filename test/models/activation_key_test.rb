#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'katello_test_helper'

module Katello
  class ActivationKeyTest < ActiveSupport::TestCase
    def setup
      @dev_key = ActivationKey.find(katello_activation_keys(:dev_key))
      @dev_view = ContentView.find(katello_content_views(:library_dev_view))
      @lib_view = ContentView.find(katello_content_views(:library_view))
    end

    test "can have content view" do
      @dev_key = ActivationKey.find(katello_activation_keys(:dev_key))
      @dev_key.content_view = @dev_view
      assert @dev_key.save!
      assert_not_nil @dev_key.content_view
      assert_includes @dev_view.activation_keys, @dev_key
    end

    test "does not require a content view" do
      assert_nil @dev_key.content_view
      assert @dev_key.save!
      assert_nil @dev_key.content_view
    end

    test "content view must be in environment" do
      @dev_key.content_view = @lib_view
      refute @dev_key.save
      refute_empty @dev_key.errors.keys
      assert_raises(ActiveRecord::RecordInvalid) do
        @dev_key.save!
      end
    end

    test "same name can be used across organizations" do
      org = Organization.find(taxonomies(:organization2))
      key = ActivationKey.find(katello_activation_keys(:simple_key))
      assert ActivationKey.new(:name => key.name, :organization => org).valid?
    end

    test "renamed key can be used again" do
      key1 = ActivationKey.find(katello_activation_keys(:simple_key))
      org = key1.organization
      original_name = key1.name
      key1.name = "new name"
      key1.save!
      assert ActivationKey.new(:name => original_name, :organization => org).valid?
    end

    test "key can be copied" do
      new_key = @dev_key.copy("new key name")
      assert_equal new_key.name, "new key name"
      assert_equal new_key.description, @dev_key.description
      assert_equal new_key.host_collections, @dev_key.host_collections
      assert_equal new_key.content_view, @dev_key.content_view
      assert_equal new_key.organization, @dev_key.organization
      assert_equal new_key.max_content_hosts, @dev_key.max_content_hosts
    end

    test "unlimited hosts requires no max hosts" do
      key1 = ActivationKey.find(katello_activation_keys(:simple_key))
      org = key1.organization
      new_key = ActivationKey.new(:name => "JarJar", :organization => org)
      new_key.unlimited_content_hosts = false
      new_key.max_content_hosts = 100
      assert new_key.valid?

      new_key.unlimited_content_hosts = true
      new_key.max_content_hosts = nil
      assert new_key.valid?

      new_key.max_content_hosts = 100
      assert !new_key.valid?
    end
  end
end
