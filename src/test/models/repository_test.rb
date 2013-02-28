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

require './test/models/repository_base'
require './test/models/authorization/repository_authorization_test'

class RepositoryCreateTest < RepositoryTestBase

  def setup
    super
    User.current = @admin
    @repo = build(:repository, :fedora_17_el6, :environment_product => EnvironmentProduct.find(environment_products(:library_fedora)),
                                              :content_view_version=>@library.default_view_version)
  end

  def teardown
    @repo.destroy
  end

  def test_create
    assert        @repo.save
    refute_empty  Repository.where(:id=>@repo.id)
  end

end


class RepositoryInstanceTest < RepositoryTestBase

  def setup
    super
    User.current = @admin
  end

  def test_product
    assert_equal @fedora, @fedora_17_x86_64.product
  end

  def test_environment
    assert_equal @library.id, @fedora_17_x86_64.environment.id
  end

  def test_organization
    assert_equal @acme_corporation.id, @fedora_17_x86_64.organization.id
  end

  def test_redhat?
    refute @fedora_17_x86_64.redhat?
  end

  def test_custom?
    assert @fedora_17_x86_64.custom?
  end

  def test_in_environment
    assert_includes Repository.in_environment(@library), @fedora_17_x86_64
  end

  def test_in_product
    assert_includes Repository.in_product(@fedora), @fedora_17_x86_64
  end

  def test_other_repos_with_same_content
    assert_includes @fedora_17_x86_64.other_repos_with_same_content, @fedora_17_x86_64_dev
  end

  def test_other_repos_with_same_product_and_content
    assert_includes @fedora_17_x86_64.other_repos_with_same_product_and_content, @fedora_17_x86_64_dev
  end

  def test_environment_id
    assert_equal @library.id, @fedora_17_x86_64.environment_id
  end

  def test_yum_gpg_key_url
    refute_nil @fedora_17_x86_64.yum_gpg_key_url
  end

  def test_clones
    assert_includes @fedora_17_x86_64.clones, @fedora_17_x86_64_dev
  end

  def test_is_cloned_in?
    assert @fedora_17_x86_64.is_cloned_in?(@dev)
  end

  def test_promoted?
    assert @fedora_17_x86_64.promoted?
  end

  def test_get_clone
    assert_equal @fedora_17_x86_64_dev, @fedora_17_x86_64.get_clone(@dev)
  end

  def test_gpg_key_name
    @fedora_17_x86_64.gpg_key_name = @unassigned_gpg_key.name

    assert_equal @unassigned_gpg_key, @fedora_17_x86_64.gpg_key
  end

  def test_as_json
    assert_includes @fedora_17_x86_64.as_json, "gpg_key_name"
  end

  def test_environmental_instances
    assert_includes @fedora_17_x86_64.environmental_instances, @fedora_17_x86_64
    assert_includes @fedora_17_x86_64.environmental_instances, @fedora_17_x86_64_dev
  end

  def test_create_clone
    clone = @fedora_17_x86_64.create_clone(@staging)
    assert clone.id
    assert Repository.in_environment(@staging).where(:library_instance_id=>@fedora_17_x86_64.id).count > 0
  end

  def test_repo_id
    @fedora             = Product.find(products(:fedora).id)
    @library            = KTEnvironment.find(environments(:library).id)
    @acme_corporation   = Organization.find(organizations(:acme_corporation).id)

    repo_id = Repository.repo_id(@fedora.label, @fedora_17_x86_64.label, @library.label,
                                 @acme_corporation.label, @library.default_content_view.label)
    assert_equal repo_id, "acme_corporation_label-library_label-library_label-fedora_label-fedora_17_x86_64_label"
  end

end
