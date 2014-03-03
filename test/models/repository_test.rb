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

require File.expand_path("repository_base", File.dirname(__FILE__))
require File.expand_path("authorization/repository_authorization_test", File.dirname(__FILE__))

module Katello
class RepositoryCreateTest < RepositoryTestBase

  def setup
    super
    User.current = @admin
    @repo = build(:repository, :fedora_17_el6,
                  :environment => @library,
                  :product => katello_products(:fedora),
                  :content_view_version => @library.default_content_view_version
                 )
  end

  def teardown
    @repo.destroy if @repo
  end

  def test_create
    assert        @repo.save
    refute_empty  Repository.where(:id=>@repo.id)
  end

  def test_create_with_no_type
    @repo.content_type = ''
    assert_raises ActiveRecord::RecordInvalid do
      @repo.save!
    end
  end

  def test_content_type
    @repo.content_type = "puppet"
    assert @repo.save
    assert_equal "puppet", Repository.find(@repo.id).content_type
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

    repo = build(:repository,
                 :content_view_version => @fedora_17_x86_64.content_view_version,
                 :product => @fedora_17_x86_64.product
                )
    assert repo.valid?
    refute_nil repo.organization
    refute repo.promoted?
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
    assert_includes @fedora_17_x86_64.environmental_instances(@acme_corporation.default_content_view), @fedora_17_x86_64
    assert_includes @fedora_17_x86_64.environmental_instances(@acme_corporation.default_content_view), @fedora_17_x86_64_dev
  end

  def test_create_clone
    @fedora_17_x86_64.stubs(:checksum_type).returns(nil)
    clone = @fedora_17_x86_64.create_clone(:environment => @staging)
    assert clone.id
    assert Repository.in_environment(@staging).where(:library_instance_id=>@fedora_17_x86_64.id).count > 0
  end

  def test_create_clone_preserve_type
    @fedora_17_x86_64.stubs(:checksum_type).returns(nil)
    @fedora_17_x86_64.content_type = 'file'
    @fedora_17_x86_64.save!
    clone = @fedora_17_x86_64.create_clone(:environment => @staging)
    assert clone.id
    assert_equal @fedora_17_x86_64.content_type, clone.content_type
  end

  def test_repo_id
    @acme_corporation   = get_organization

    @fedora             = Product.find(katello_products(:fedora).id)
    @library            = KTEnvironment.find(katello_environments(:library).id)

    repo_id = Repository.repo_id(@fedora.label, @fedora_17_x86_64.label, @library.label,
                                 @acme_corporation.label, @library.default_content_view.label, nil)
    assert_equal "Empty_Organization-library_label-org_default_label-fedora_label-fedora_17_x86_64_label", repo_id
  end

  def test_clone_repo_path_for_component
    skip "TODO: Fix content views"
    # validate that clone repo path for a component view does not include the component view label
    @content_view_definition = katello_content_view_definition_bases(:composite_def)
    dev = KTEnvironment.find(katello_environments(:dev).id)
    cv = @content_view_definition.component_content_views.where(:label => "component_view_1").first
    cve = ContentViewEnvironment.where(:environment_id => dev,
                                        :content_view_id => cv).first

    relative_path = Repository.clone_repo_path(@fedora_17_x86_64, dev, cv)
    assert_equal "/#{cve.label}/library/fedora_17_label", relative_path
  end

  def test_blank_feed_url
    new_custom_repo = @fedora_17_x86_64.clone
    new_custom_repo.name = "new_custom_repo"
    new_custom_repo.label = "new_custom_repo"
    new_custom_repo.pulp_id = "new_custom_repo"
    new_custom_repo.feed = ""
    assert new_custom_repo.save
    assert new_custom_repo.persisted?
    assert_equal "", new_custom_repo.reload.feed
    refute new_custom_repo.feed?

    rhel = Repository.find(katello_repositories(:rhel_6_x86_64))
    rhel.feed = ""
    refute rhel.valid?
    refute rhel.save
    refute_empty rhel.errors
  end
end
end
