#
# Copyright 2014 Red Hat, Inc.
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
class ContentViewFilterTest < ActiveSupport::TestCase

  def self.before_suite
    models = ["Organization", "LifecycleEnvironment", "User", "ContentViewFilter", "ContentViewVersion",
              "ContentViewEnvironment", "ContentView", "Product", "Repository"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch"], models, true)
  end

  def setup
    User.current = User.find(users(:admin))
    @filter = FactoryGirl.build(:katello_content_view_filter)
    @repo = Repository.find(katello_repositories(:fedora_17_x86_64).id)
    ContentView.any_instance.stubs(:reindex_on_association_change).returns(true)
  end

  def test_create
     assert @filter.save
  end

  def test_composite_view
    skip "skip until composite content views are supported"
    # filter should not get created for a composite content view
    content_view = FactoryGirl.create(:katello_content_view, :composite)
    filter = FactoryGirl.build(:katello_content_view_filter, :content_view_id => content_view.id)
    assert_nil ContentViewFilter.find_by_id(filter.id)
    refute ContentViewFilter.exists?(filter.id)
  end

  def test_bad_name
    filter = FactoryGirl.build(:katello_content_view_filter, :name => "")
    assert filter.invalid?
    assert filter.errors.has_key?(:name)
  end

  def test_duplicate_name
    @filter.save!
    attrs = FactoryGirl.attributes_for(:katello_content_view_filter,
                                       :name => @filter.name,
                                       :content_view_id => @filter.content_view_id
                                      )
    assert_raises(ActiveRecord::RecordInvalid) do
      ContentViewFilter.create!(attrs)
    end
    filter_item = ContentViewFilter.create(attrs)
    refute filter_item.persisted?
    refute filter_item.save
  end

  def test_add_bad_repo
    @filter.repositories << @repo
    assert_raises(ActiveRecord::RecordInvalid) do
      @filter.save!
    end
  end

  def test_add_good_repo
    view =  @filter.content_view
    view.repositories << @repo
    view.save!
    @filter.repositories << @repo
    assert @filter.save
    refute_empty ContentViewFilter.find(@filter.id).repositories
  end

  def test_content_view_delete_repo
    @filter.save!
    view =  @filter.content_view
    view.repositories << @repo
    view.save!
    @repo = Repository.find(@repo.id)
    @filter = ContentViewFilter.find(@filter.id)
    refute_empty @filter.content_view.repositories
    @repo = Repository.find(@repo.id)
    @filter.repositories << @repo
    @filter.save!
    view  = ContentView.find(view)
    view.repositories.delete(@repo)
    view.save!
    assert_empty view.filters.first.repositories
  end

end
end
