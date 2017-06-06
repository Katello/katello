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

class ContentViewVersionTest < MiniTest::Rails::ActiveSupport::TestCase

  def self.before_suite
    models = ["Organization", "KTEnvironment", "User", "ContentViewEnvironment"]
    services = ["Candlepin", "Pulp", "ElasticSearch"]
    disable_glue_layers(services, models)
  end

  def after_tests
    ContentViewDefinition.delete_all
    ContentView.delete_all
    Organization.delete_all
  end

  def test_create_archived_definition
    definition = FactoryGirl.create(:content_view_definition)
    version = FactoryGirl.create(:content_view_version)
    version.save!
    assert_nil version.definition_archive # no archive if no definition
    version.content_view.content_view_definition = definition
    version.save!
    assert_equal definition.label, version.definition_archive.label
  end

end
