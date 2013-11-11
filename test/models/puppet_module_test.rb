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

require 'katello_test_helper'

module Katello
class PuppetModuleTest < ActiveSupport::TestCase

  def test_parse_metadata
    filepath = File.join(Katello::Engine.root, "test/fixtures/puppet/puppetlabs-ntp-2.0.1.tar.gz")
    metadata = PuppetModule.parse_metadata(filepath)

    assert_equal "Puppet Labs", metadata[:author]
    assert_equal "puppetlabs-ntp", metadata[:name]
    assert_equal "2.0.1", metadata[:version]
    assert_equal "NTP Module", metadata[:summary]
  end

  def test_parse_metadata_with_bad_file
    filepath = __FILE__
    assert_raises(InvalidPuppetModuleError) do
      PuppetModule.parse_metadata(filepath)
    end
  end
end
end
