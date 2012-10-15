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

class ContentViewTest < MiniTest::Rails::ActiveSupport::TestCase

  def test_create
    assert ContentView.create(attributes_for(:content_view))
  end

  def test_create_with_content_view_definition
    content_view = FactoryGirl.build(:content_view, :with_definition)
    refute content_view.content_view_definition.nil?
    assert content_view.save
  end

  def test_create_without_content_view_definition
    content_view = FactoryGirl.build(:content_view)
    assert content_view.content_view_definition.nil?
    assert content_view.save
  end

  def test_bad_name
    content_view = FactoryGirl.build(:content_view, :name => "")
    assert content_view.invalid?
    refute content_view.save
    assert content_view.errors.has_key?(:name)
  end

  def test_component_content_views
    content_view = FactoryGirl.create(:content_view_with_definition)
    component = FactoryGirl.create(:content_view)
    content_view.component_content_views << component

    refute_empty content_view.component_content_views
    assert_includes component.composite_content_views, content_view
  end

  def test_content_view_environments
    env = FactoryGirl.build_stubbed(:environment)
    content_view = FactoryGirl.create(:content_view)
    content_view.environments << env

    assert_includes env.content_views.reload, content_view
  end

  def test_environment_default_content_view
    # disable glue layer
    services  = ['Candlepin', 'Pulp', 'ElasticSearch']
    models = ["User", "Organization", "KTEnvironment"]
    disable_glue_layers(services, models)

    env = FactoryGirl.create(:environment_with_library)
    content_view = FactoryGirl.create(:content_view)
    env.update_attributes(:default_content_view_id => content_view.id)
    assert_includes content_view.environment_defaults.reload, env.reload
  end

end
