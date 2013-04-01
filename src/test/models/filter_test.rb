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

class FilterTest < MiniTest::Rails::ActiveSupport::TestCase
  fixtures :all

  def self.before_suite
    models = ["Organization", "KTEnvironment", "User","Filter", "ContentViewEnvironment",
              "ContentViewDefinition", "Product", "Repository"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models)
  end

  def setup
    #User.current = User.find(users(:admin))
    @filter = FactoryGirl.build(:filter)
    @repo = Repository.find(repositories(:fedora_17_x86_64).id)
    @product = Product.find(products(:fedora).id)
  end

  def after_tests
    Filter.delete_all
    ContentViewDefinition.delete_all
    Organization.delete_all
    Product.delete_all
    Repository.delete_all
  end

  def test_create
     assert @filter.save
  end

  def test_bad_name
    filter = FactoryGirl.build(:filter, :name => "")
    assert filter.invalid?
    assert filter.errors.has_key?(:name)
  end

  def test_duplicate_name
    @filter.save!
    attrs = FactoryGirl.attributes_for(:filter,
                                       :name => @filter.name,
                                       :content_view_definition_id => @filter.content_view_definition_id
                                      )
    assert_raises(ActiveRecord::RecordInvalid) do
      Filter.create!(attrs)
    end
    f = Filter.create(attrs)
    refute f.persisted?
    refute f.save
  end

  def test_add_bad_repo
    @filter.repositories << @repo
    assert_raises(ActiveRecord::RecordInvalid) do
      @filter.save!
    end
  end

  def test_add_good_repo
    cvd =  @filter.content_view_definition
    cvd.repositories << @repo
    cvd.save!
    @filter.repositories << @repo
    assert @filter.save
    refute_empty Filter.find(@filter.id).repositories
  end

  def test_add_bad_product
    @filter.products << @product
    assert_raises(ActiveRecord::RecordInvalid) do
      @filter.save!
    end
  end

  def test_add_good_product
    cvd =  @filter.content_view_definition
    cvd.products << @product
    cvd.save!
    @filter.products << @product
    assert @filter.save
    refute_empty Filter.find(@filter.id).products
  end

  def test_archive
    filter = create(:filter)
    filter_count = Filter.count
    archive = filter.content_view_definition.archive
    refute_empty archive.filters
    assert_equal filter_count+1, Filter.count
    refute_equal filter.content_view_definition.filters.map(&:id).sort,
      archive.filters.map(&:id).sort
  end

  # TODO work to fix these later..
  #def test_content_definition_delete_repo
  #  @filter.save!
  #  cvd =  @filter.content_view_definition
  #  cvd.repositories << @repo
  #  cvd.save!
  #  @repo = Repository.find(@repo.id)
  #  @filter = Filter.find(@filter.id)
  #  #debugger
  #  refute_empty @filter.content_view_definition.repositories
  #  @repo = Repository.find(@repo.id)
  #  #assert @filter.content_view_definition.repositories.include?(@repo)
  #  @filter.repositories << @repo
  #  @filter.save!
  #  cvd = ContentViewDefinition.find(cvd.id)
  #  cvd.repositories.delete(@repo)
  #  assert_empty cvd.filters.first.repositories
  #  cvd.save!
  #  assert_empty cvd.filters.first.repositories
  #end
  #
  #def test_content_definition_delete_product
  #  @filter.save!
  #  cvd =  @filter.content_view_definition
  #  cvd.products << @product
  #  cvd.save!
  #  @repo = Repository.find(@product.id)
  #  @filter = Filter.find(@filter.id)
  #  @filter.products << @product
  #  @filter.save!
  #  cvd = ContentViewDefinition.find(cvd.id)
  #  cvd.products.delete(@product)
  #  assert_empty cvd.filters.first.products
  #  cvd.save!
  #end

end
