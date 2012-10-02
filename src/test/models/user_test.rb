#
# Copyright 2012 Red Hat, Inc.
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


module TestUserBase

  def setup
    AppConfig.use_cp = false
    AppConfig.use_pulp = false

    Object.send(:remove_const, 'User')
    load 'app/models/user.rb'
  end

end


class UserCreateTest < MiniTest::Rails::ActiveSupport::TestCase
  include TestUserBase

  def setup
    super
    @user = User.new(:username => "Bob", :email => "test@test.com", :password => "Villa")
  end

  def teardown
    @user.destroy
  end

  def test_create
    assert @user.save
  end

  def test_create_with_short_password
    @user.password = "a"
    assert !@user.save
    assert @user.errors.has_key?(:password)
  end

  def test_before_create_self_role
    @user.save
    assert !@user.own_role.nil?
  end

  def test_before_save_hash_password
    @user.save
    assert @user.password != "Villa"
  end

end


class UserTest < MiniTest::Rails::ActiveSupport::TestCase
  include TestUserBase
  self.use_instantiated_fixtures = false
  fixtures :users, :roles, :permissions, :resource_types, :roles_users

  def setup
    super
    @user = User.find(users(:alfred))
  end

  def test_destroy
    @user.destroy
    assert @user.destroyed?
  end

  def test_before_destroy_remove_self_role
    role = @user.own_role
    @user.destroy
    assert_raises ActiveRecord::RecordNotFound do 
      Role.find(role.id)
    end
  end

  def test_before_destroy_not_last_superuser
    admin = User.find(users(:admin))
    assert !admin.destroy
  end

end


class UserTest < MiniTest::Rails::ActiveSupport::TestCase
  include TestUserBase
  self.use_instantiated_fixtures = false
  fixtures :users, :roles, :permissions, :resource_types, :roles_users

  def test_authenticate
    assert User.authenticate!(users(:alfred).username, users(:alfred).username)
  end

  def test_authenticate_fails_with_wrong_password
    assert_nil User.authenticate!(users(:alfred).username, '')
  end

  def test_authenticate_fails_with_non_user
    assert_nil User.authenticate!('fake_user', '')
  end

  def test_authenticate_fails_with_disabled_user
    assert_nil User.authenticate!(users(:disabled_user).username, users(:disabled_user).password)
  end

end
