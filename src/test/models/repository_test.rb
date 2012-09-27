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
require 'test/models/authorization/repository_authorization_test'


module RepositoryTestBase
  def self.included(base)
    base.class_eval do
      set_fixture_class :environments => KTEnvironment
      self.use_instantiated_fixtures = false
      fixtures :organizations, :environments, :providers, :products, :repositories
      fixtures :roles, :permissions, :resource_types, :users, :roles_users
      fixtures :environment_products, :gpg_keys
    end
  end

  def setup
    AppConfig.use_cp = false
    AppConfig.use_pulp = false
    AppConfig.use_elasticsearch = false

    Object.send(:remove_const, 'Repository')
    load 'app/models/repository.rb'

    @fedora_17        = Repository.find(repositories(:fedora_17).id)
    @fedora_17_dev    = Repository.find(repositories(:fedora_17_dev).id)
    @fedora           = Product.find(products(:fedora).id)
    @library          = KTEnvironment.find(environments(:library).id)
    @dev              = KTEnvironment.find(environments(:dev).id)
    @acme_corporation = Organization.find(organizations(:acme_corporation).id)
  end

end


class RepositoryCreateTest < MiniTest::Rails::ActiveSupport::TestCase
  include RepositoryTestBase

  def setup
    super
    @repo = Repository.new(:name => 'repository_test_name', :pulp_id => 'This is not a feal pulp ID', 
                          :environment_product_id => environment_products(:library_fedora).id, :content_id => 'FakeContentID')
  end

  def teardown
    @repo.destroy
  end

  def test_create
    assert @repo.save
  end

end


class RepositoryInstanceTest < MiniTest::Rails::ActiveSupport::TestCase
  include RepositoryTestBase

  def test_product
    assert @fedora == @fedora_17.product
  end

  def test_environment
    assert @library == @fedora_17.environment
  end

  def test_organization
    assert @acme_corporation == @fedora_17.organization
  end

  def test_redhat?
    assert !@fedora_17.redhat?
  end

  def test_custom?
    assert @fedora_17.custom?
  end

  def test_yum_gpg_key_url
    assert !@fedora_17.yum_gpg_key_url.nil?
  end

  def test_has_filters?
    assert !@fedora_17.has_filters?
  end

  def test_synx_complete
    assert false
  end

  def test_clones
    assert @fedora_17.clones == [@fedora_17_dev]
  end

  def test_is_cloned_in?
    assert @fedora_17.is_cloned_in?(@dev)
  end

  def test_promoted?
    assert @fedora_17.promoted?
  end

  def test_get_clone
    assert @fedora_17.get_clone(@dev) == @fedora_17_dev
  end

  def test_gpg_key_name
    assert false
  end

  def test_as_json
    assert @fedora_17.as_json.has_key? "gpg_key_name"
  end

  def test_environmental_instances
    assert @fedora_17.environmental_instances.include?([@fedora_17, @fedora_17_dev])
  end

  def test_errata_count
    assert @fedora_17.errata_count
  end

  def test_package_count
    assert @fedora_17.package_count
  end

  def test_applicable_filters
    assert @fedora_17.applicable_filters == []
  end

end
