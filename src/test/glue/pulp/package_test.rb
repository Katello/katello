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

=begin
module GluePulpPackageTestBase

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

    VCR.insert_cassette('glue_pulp_package')
  end

  def teardown
  rescue
  ensure
    VCR.eject_cassette
  end

end

class GluePulpPackageTest < MiniTest::Unit::TestCase
  include GluePulpPackageTestBase

  def test_find
    package = Glue::Pulp::Package.find(@package.id)
    assert package.name == "elephant"
  end

  def test_nvrea
    package = Glue::Pulp::Package.find(@package.id)
    assert package.nvrea == "elephant-0.3-0.8.noarch"
  end

end
=end
