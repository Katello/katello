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
    @user = User.new(:username => @username, :email => "test@test.com", :password => "test_password")

    VCR.configure do |c|
      c.default_cassette_options = { :record => :once } #record_mode } #forcing all requests to Pulp currently
    end
    VCR.insert_cassette('glue_pulp_user')
  end

  def teardown
    @user.del_pulp_user
  rescue => e
  ensure
    VCR.eject_cassette
  end

end


class TestUser < MiniTest::Rails::ActiveSupport::TestCase
  include TestUserBase

  def test_create
    assert @user.save
  end

  def test_destroy
    @user.save
    @user.destroy
    assert User.where(:username => @username).length == 0
  end

end
