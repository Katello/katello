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

class ContentViewDefinitionTest < MiniTest::Rails::ActiveSupport::TestCase
  fixtures :all

  def self.before_suite
    models = ["Organization", "KTEnvironment", "ContentViewEnvironment", "User", "Product", "Repository"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
  end

  def setup
    User.current = User.find(users(:admin))
    @content_view_def = FactoryGirl.build(:content_view_definition)
    @repo = Repository.find(repositories(:fedora_17_x86_64).id)
    @product               = Product.find(products(:fedora).id)
  end

  def after_tests
    ContentViewDefinition.delete_all
    ContentView.delete_all
    Organization.delete_all
    Product.delete_all
    Repository.delete_all
  end

  def test_create
    assert @content_view_def.save
  end

  def test_bad_name
    content_view_def = FactoryGirl.build(:content_view_definition, :name => "")
    assert content_view_def.invalid?
    assert content_view_def.errors.has_key?(:name)
  end

  def test_duplicate_name
    attrs = FactoryGirl.attributes_for(:content_view_definition,
                                       :name => @content_view_def.name
                                      )
    assert_raises(ActiveRecord::RecordInvalid) do
      ContentViewDefinition.create!(attrs)
    end
    cv = ContentViewDefinition.create(attrs)
    refute cv.persisted?
    refute cv.save
  end

  def test_destroy_with_content_views
    content_view = FactoryGirl.create(:content_view)
    definition = FactoryGirl.create(:content_view_definition,
                                    :content_views => [content_view])
    assert definition.destroy
    assert_nil ContentView.find_by_id(content_view.id)
  end

  def test_products
    @content_view_def.save!
    @content_view_def.products << @product
    assert_includes @product.content_view_definitions.reload, @content_view_def
  end

  def test_repos
    @content_view_def.save!
    @content_view_def.repositories << @repo
    @content_view_def = @content_view_def.reload
    assert_equal @repo.content_view_definitions.first, @content_view_def
    assert_includes @content_view_def.repositories.map(&:id), @repo.id
  end

  def test_adding_products_to_composite_view
    # verify that products cannot be added to a composite view
    @content_view_def.composite = true
    @content_view_def.products << FactoryGirl.build_stubbed(:product)
    refute @content_view_def.save
    refute_empty @content_view_def.errors
  end

  def test_adding_views_to_composite_content_definition
    # verify that component views may be added to a composite view
    @content_view_def.composite = true
    @content_view_def.component_content_views << FactoryGirl.create(:content_view)
    assert @content_view_def.save
  end

  def test_publish
    content_view_def = FactoryGirl.create(:content_view_definition)
    content_view = content_view_def.publish('test_name', 'test_description', 'test_label')
    refute_nil content_view
    refute_empty content_view_def.content_views.reload
    assert_includes content_view_def.content_views, content_view

    content_view.versions.each do |v|
      assert_equal content_view_def.id, v.definition_archive.source_id
    end
  end

  def test_publish_composite
    content_view_def = FactoryGirl.create(:content_view_definition)
    content_view_def.composite = true
    content_view_def.save!
    content_view = content_view_def.publish('test_name', 'test_description', 'test_label')
    refute_nil content_view
    refute_empty content_view_def.content_views.reload
    assert_includes content_view_def.content_views, content_view
    content_view.versions.each { |v| refute_nil v.definition_archive }
  end

  def test_archive
    content_view_def = FactoryGirl.create(:content_view_definition)
    assert content_view_def.archive
    assert_equal 2, ContentViewDefinitionBase.where(:name => content_view_def.name).count
    assert_equal 2, ContentViewDefinitionBase.where(:label => content_view_def.label).count
    assert_equal ContentViewDefinitionArchive.find_all_by_label(content_view_def.label), content_view_def.archives
  end

end
