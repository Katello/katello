#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'minitest_helper'

class ActivationKeyTest < MiniTest::Rails::ActiveSupport::TestCase
  fixtures :all

  def setup
    @dev_key = activation_keys(:dev_key)
    @dev_view = content_views(:library_dev_view)
    @lib_view = content_views(:library_view)
  end

  test "can have content view" do
    @dev_key = activation_keys(:dev_key)
    @dev_key.content_view = @dev_view
    assert @dev_key.save!
    assert_not_nil @dev_key.content_view
    assert_includes @dev_view.activation_keys, @dev_key
  end

  test "requires a content view" do
    assert_nil @dev_key.content_view
    refute @dev_key.save
    assert_raises(ActiveRecord::RecordInvalid) do
      @dev_key.save!
    end
  end

  test "content view must be in environment" do
    @dev_key.content_view = @lib_view
    refute @dev_key.save
    refute_empty @dev_key.errors.keys
    assert_raises(ActiveRecord::RecordInvalid) do
      @dev_key.save!
    end
  end

end
