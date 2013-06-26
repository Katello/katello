# encoding: UTF-8
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

class ContentViewDefinitionTest < MiniTest::Rails::ActiveSupport::TestCase
  fixtures :all

  def self.before_suite
    models = ["Product", "Repository","Organization", "KTEnvironment", "ContentViewDefinitionBase",
              "ContentViewDefinition", "ContentViewEnvironment",
              "ContentViewDefinitionRepository", "ContentViewDefinitionProduct", "ContentViewVersion",
              "User"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch", "Foreman"], models, true)
  end

  def setup
    User.current = User.find(users(:admin))
    @content_view_def = ContentViewDefinition.find(content_view_definition_bases(:simple_cvd).id)
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

  def test_utf8_name
    content_view_def = FactoryGirl.build(:content_view_definition, :name => "올드보이")
    assert content_view_def.valid?
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

  def test_repositories
    @content_view_def.save!
    @content_view_def.repositories << @repo
    @content_view_def = @content_view_def.reload
    assert_includes @repo.content_view_definitions, @content_view_def
    assert_includes @content_view_def.repositories.map(&:id), @repo.id
  end

  def test_repos_includes_repo
    @content_view_def.repositories << @repo
    assert_includes @content_view_def.repos, @repo
  end

  def test_repos_includes_product_repo
    @content_view_def.products << @repo.product
    @content_view_def.save!

    assert_includes @content_view_def.repos.map(&:id), @repo.id
  end

  def test_repos_includes_file_types
    @repo.content_type = Repository::FILE_TYPE
    @repo.save!
    @content_view_def.products << @repo.product

    assert_includes @content_view_def.repos.map(&:id), @repo.id
  end

  def test_adding_products_to_composite_view
    # verify that products cannot be added to a composite view
    @content_view_def.composite = true
    @content_view_def.products << @repo.product
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

  def test_copy
    content_view_def = FactoryGirl.create(:content_view_definition)
    count = ContentViewDefinition.count
    assert_raises(ActiveRecord::RecordInvalid) do
      content_view_def.copy
    end
    assert content_view_def.copy(:name => "HydrogenSonata")
    assert_equal count+1, ContentViewDefinition.count
  end

  def test_validate_component_views
    content_view_def = FactoryGirl.create(:content_view_definition, :composite)
    ContentView.any_instance.stubs(:library_repo_ids).returns([1])
    content_views = FactoryGirl.create_list(:content_view, 2)

    content_view_def.component_content_views << content_views.first
    assert_raises(Errors::ContentViewRepositoryOverlap) do
      content_view_def.component_content_views << content_views.last
    end
    assert_equal 1, content_view_def.component_content_views.reload.length
  end

  def test_validate_component_views_before_add
    content_view_def = content_view_definition_bases(:simple_cvd)
    ContentView.any_instance.stubs(:library_repo_ids).returns([1])
    content_view = content_views(:library_dev_view)

    assert_raises(Errors::ContentViewDefinitionBadContent) do
      content_view_def.component_content_views << content_view
    end
    assert_empty content_view_def.component_content_views
  end

end
