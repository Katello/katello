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


module TestGluePulpUserBase

  def setup
    uri = URI.parse(AppConfig.pulp.url)
    Runcible::Base.config = { 
      :url      => "#{uri.scheme}://#{uri.host}",
      :api_path => uri.path,
      :user     => "admin",
      :oauth    => {:oauth_secret => AppConfig.pulp.oauth_secret,
                    :oauth_key    => AppConfig.pulp.oauth_key },
      :logger   => RestClient.log
    }

    @username = "test_username"
    @user = User.new(:name => @username, :username => "test_username")

    VCR.insert_cassette('glue_pulp_user')
  end

  def teardown
    @user.del_pulp_user
  rescue => e
  ensure
    VCR.eject_cassette
  end

end


class TestGluePulpUser < MiniTest::Unit::TestCase
  include TestGluePulpUserBase

  def test_set_pulp_user
    assert @user.set_pulp_user
  end

  def test_set_pulp_user_raises_exception
    @user.username = nil
    assert_raises RestClient::InternalServerError do 
      @user.set_pulp_user
    end
  end

  def test_set_super_user_role
    @user.set_pulp_user
    assert @user.set_super_user_role
  end

  def test_del_super_admin_role
    @user.set_pulp_user
    @user.set_super_user_role
    assert @user.del_super_admin_role
  end
  
  def test_del_pulp_user
    @user.set_pulp_user
    assert @user.del_pulp_user
  end

  def test_del_pulp_user
    assert_raises RestClient::ResourceNotFound do 
      @user.del_pulp_user
    end
  end

  def test_initialize
    attributes = @user.attributes.merge({:backend_attribute_only => "This is a backend only attribute"})
    attributes = @user.prune_pulp_only_attributes(attributes)
    assert !attributes.has_key?(:backend_attribute_only)
  end

  def test_lazy_accessor
    login = @user.login
    debugger
    assert login == "test_username"
  end

end
