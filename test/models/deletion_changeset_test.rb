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
class DeletionChangesetTest < ActiveSupport::TestCase

  def self.before_suite
    models = ["Organization", "ContentView", "Product", "ContentViewEnvironment", "KTEnvironment",
              "ContentViewVersion", "Repository", "Changeset", "DeletionChangeset"]
    disable_glue_layers(["Candlepin", "Pulp", "ElasticSearch", "Foreman"], models)
  end

  def setup
    @acme_corporation     = get_organization

    @library              = KTEnvironment.find(katello_environments(:library).id)
    @dev                  = KTEnvironment.find(katello_environments(:dev).id)
    @product              = Product.find(katello_products(:fedora))
    @repo_dev             = Repository.find(katello_repositories(:fedora_17_x86_64_dev))
    @repo_library         = Repository.find(katello_repositories(:fedora_17_x86_64))
    @library_dev_view     = ContentView.find(katello_content_views(:library_dev_view))

    @changeset            = DeletionChangeset.create!(:name =>'PrecreatedCS',
                                              :environment_id => @dev.id)
    DeletionChangeset.any_instance.stubs(:index_repo_content)
    ContentViewEnvironment.any_instance.stubs(:update_cp_content)
  end

  def test_creation
    cs = DeletionChangeset.create!(:name =>'TestDeleteCS',
                                          :environment_id => @dev.id)
    assert_not_nil DeletionChangeset.find(cs.id)
  end

  def test_create_in_library_should_fail
    assert_raises(ActiveRecord::RecordInvalid) do
      DeletionChangeset.create!(:name =>'TestDeleteCS',
                                            :environment_id => @library.id)
    end
  end

  def test_cs_promote_from_wrong_state
    assert_raises(RuntimeError) do
      @changeset.apply(:async=>false)
    end
  end

  def test_cs_promote_state
    @changeset.state = Changeset::REVIEW
    @changeset.apply(:async=>false)
    assert_equal Changeset::DELETED, @changeset.state
  end

  def test_content_view_delete
    assert_includes @library_dev_view.environments, @dev
    @changeset.add_content_view!(@library_dev_view)
    @changeset.state = Changeset::REVIEW
    @changeset.apply(:async=>false)

    refute_includes ContentView.find(@library_dev_view).environments, @dev
  end

end
end
