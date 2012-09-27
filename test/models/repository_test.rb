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


module RepositoryTestBase
  def self.included(base)
    base.class_eval do
      set_fixture_class :environments => KTEnvironment
      fixtures :organizations, :environments, :providers, :products, :repositories
      fixtures :roles, :permissions, :resource_types, :users, :roles_users
      fixtures :environment_products, :gpg_keys
    end
  end

  def setup
    AppConfig.use_cp = false
    AppConfig.use_pulp = false

    Object.send(:remove_const, 'Repository')
    load 'app/models/repository.rb'

    @fedora_17        = repositories(:fedora_17)
    @fedora           = products(:fedora)
    @library          = environments(:library)
    @acme_corporation = organizations(:acme_corporation)
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


class RepositoryClassTest < MiniTest::Rails::ActiveSupport::TestCase
  include RepositoryTestBase

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

end


class RepositoryPermissionTest < MiniTest::Rails::ActiveSupport::TestCase
  include RepositoryTestBase

  def setup
    super
    User.current = users(:admin)
  end

  def test_readable
    assert Repository.readable(@library)
  end

  def test_libraries_content_readable
    assert Repository.libraries_content_readable(@acme_corporation)
  end

  def test_content_readable
    assert Repository.content_readable(@acme_corporation)
  end

  def test_readable_for_product
    assert Repository.readable_for_product(@library, @fedora)
  end

  def test_editable_in_library
    assert Repository.editable_in_library(@acme_corporation)
  end

  def test_readable_in_org
    assert Repository.readable_in_org(@acme_corporation)
  end

  def test_any_readable_in_org?
    assert Repository.any_readable_in_org?(@acme_corporation)
  end

end
