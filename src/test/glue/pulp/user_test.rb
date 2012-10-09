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


module GluePulpUserTestBase

  def setup
    configure_vcr
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
    VCR.use_cassette('pulp_user_setup') do
      @user.del_pulp_user
    end
  rescue => e
  ensure
    VCR.eject_cassette
  end

end


class GluePulpUserCreateTest < MiniTest::Unit::TestCase
  include GluePulpUserTestBase

  def test_set_pulp_user
    assert @user.set_pulp_user
  end

  def test_del_pulp_user
    VCR.use_cassette('pulp_user_exception_raised') do
      assert_raises RestClient::ResourceNotFound do 
        @user.del_pulp_user
      end
    end
  end

end


class GluePulpUserTest < MiniTest::Unit::TestCase
  include GluePulpUserTestBase

  def setup
    super
    VCR.use_cassette('pulp_user_setup') do
      @user.set_pulp_user
    end
  end

  def test_set_pulp_user_raises_exception
    @user.username = nil
    VCR.use_cassette('pulp_user_exception_raised') do
      assert_raises RestClient::InternalServerError do 
        @user.set_pulp_user
      end
    end
  end

  def test_set_super_user_role
    assert @user.set_super_user_role
  end

  def test_del_super_admin_role
    @user.set_super_user_role
    assert @user.del_super_admin_role
  end
  
  def test_del_pulp_user
    assert @user.del_pulp_user
  end

  def test_prune_pulp_only_attributes
    attributes = @user.attributes.merge({:backend_attribute_only => "This is a backend only attribute"})
    attributes = @user.prune_pulp_only_attributes(attributes)
    assert !attributes.has_key?(:backend_attribute_only)
  end

end
