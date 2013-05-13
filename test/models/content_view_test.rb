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

class ContentViewTest < MiniTest::Rails::ActiveSupport::TestCase
  fixtures :all

  def self.before_suite
    models = ["Organization", "KTEnvironment", "User", "ContentViewEnvironment","ContentViewDefinitionBase",
              "ContentViewDefinition", "Repository", "ContentView", "EnvironmentProduct", "ContentViewVersion",
              "ComponentContentView", "System"]
    services = ["Candlepin", "Pulp", "ElasticSearch"]
    disable_glue_layers(services, models, true)
  end

  def setup
    User.current      = User.find(users(:admin))
    @library          = KTEnvironment.find(environments(:library).id)
    @dev              = KTEnvironment.find(environments(:dev).id)
    @acme_corporation = Organization.find(organizations(:acme_corporation).id)
    @default_view     = ContentView.find(content_views(:acme_default))
    @library_view     = ContentView.find(content_views(:library_view))
    @library_dev_view = ContentView.find(content_views(:library_dev_view))
  end

  def test_create
    assert ContentView.create(FactoryGirl.attributes_for(:content_view))
  end

  def test_label
    content_view = FactoryGirl.build(:content_view)
    content_view.label = ""
    assert content_view.save
    assert content_view.label.present?
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

  def test_duplicate_name
    attrs = FactoryGirl.attributes_for(:content_view,
                                       :name => @library_dev_view.name
                                      )
    assert_raises(ActiveRecord::RecordInvalid) do
      ContentView.create!(attrs)
    end
    cv = ContentView.create(attrs)
    refute cv.persisted?
    refute cv.save
  end

  def test_bad_label
    content_view = FactoryGirl.build(:content_view)
    content_view.label = "Bad Label"

    assert content_view.invalid?
    #TODO: RAILS32 Re-work for Rails 3.2
    #assert_equal 1, content_view.errors.length
    assert content_view.errors.has_key?(:label)
  end

  def test_component_content_views
    content_view = FactoryGirl.create(:content_view_with_definition)
    definition = FactoryGirl.create(:content_view_definition, :composite)
    definition.component_content_views << content_view

    refute_empty definition.component_content_views
    refute_empty definition.components
    assert_includes definition.component_content_views, content_view
    assert_includes content_view.composite_content_view_definitions, definition
  end

  def test_content_view_environments
    assert_includes @library_view.environments, @library
    assert_includes @library.content_views, @library_view
  end

  def test_environment_default_content_view_destroy
    env = @dev
    content_view = @dev.default_content_view
    env.destroy
    refute_nil ContentView.find_by_id(content_view.id)
  end

  def test_environment_default_content_view_version_destroy
    env = @dev
    version = @dev.default_content_view_version
    env.destroy
    assert_nil ContentViewVersion.find_by_id(version.id)
  end

  def test_changesets
    content_view = FactoryGirl.create(:content_view)
    environment = FactoryGirl.build_stubbed(:environment)
    changeset = FactoryGirl.create(:changeset, :environment => environment)
    content_view.changesets << changeset
    assert_includes changeset.content_views.map(&:id), content_view.id
    assert_equal content_view.changeset_content_views,
      changeset.changeset_content_views
  end

  def test_promote
    Repository.any_instance.stubs(:clone_contents).returns([])
    content_view = @library_view
    refute_includes content_view.environments, @dev
    content_view.promote(@library, @dev)
    assert_includes content_view.environments, @dev
    refute_empty ContentViewEnvironment.where(:label => content_view.cp_environment_label(@dev))
  end

  def test_destroy
    count = ContentView.count
    refute @library_dev_view.destroy
    assert ContentView.exists?(@library_dev_view.id)
    assert_equal count, ContentView.count
    assert @library_view.destroy
    assert_equal count-1, ContentView.count
  end

  def test_delete
    view = @library_dev_view
    view.delete(@dev)
    refute_includes view.environments, @dev
  end

  def test_delete_last_env
    view = @library_view
    view.delete(@library)
    assert_empty ContentView.where(:label=>view.label)
  end

  def test_default_scope
    refute_empty ContentView.default
    assert_empty ContentView.default.select{|v| !v.default}
    assert_includes ContentView.default, @library.default_content_view
  end

  def test_non_default_scope
    refute_empty ContentView.non_default
    assert_empty ContentView.non_default.select{|v| v.default}
  end

  def test_destroy_content_view_versions
    content_view = @library_view
    content_view_version = @library_view.versions.first
    refute_nil content_view_version
    assert content_view.destroy
    assert_nil ContentViewVersion.find_by_id(content_view_version.id)
  end

  def test_all_version_library_instances_empty
    assert_empty @library_dev_view.all_version_library_instances
  end

  def test_all_version_library_instances_empty
    refute_empty @library_view.all_version_library_instances
  end

  def test_components_not_in_env
    composite_view = content_views(:composite_view)

    assert_equal 2, composite_view.components_not_in_env(@dev).length
    assert_equal composite_view.content_view_definition.component_content_views,
      composite_view.components_not_in_env(@dev)
  end
end
