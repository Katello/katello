# encoding: utf-8
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
class KTEnvironmentTestBase < ActiveSupport::TestCase

  extend ActiveRecord::TestFixtures

  def self.before_suite
    services  = ['Candlepin', 'Pulp', 'ElasticSearch', 'Foreman']
    models    = ['Repository', 'KTEnvironment', 'ContentView', 'ContentViewVersion',
                 'ContentViewEnvironment', 'Organization', 'Product',
                 'Provider']
    disable_glue_layers(services, models, true)
  end

  def setup
    @acme_corporation     = get_organization

    @library              = KTEnvironment.find(katello_environments(:library).id)
    @dev                  = KTEnvironment.find(katello_environments(:dev).id)
    @staging              = KTEnvironment.find(katello_environments(:staging).id)
  end

end


class KTEnvironmentTest < KTEnvironmentTestBase

  def test_create_and_validate_default_content_view
    env = KTEnvironment.create(:organization=>@acme_corporation, :name=>"SomeEnv", :prior=>@library)
    assert_nil env.default_content_view
    assert_nil env.default_content_view_version
  end

  def test_destroy_env_with_systems_should_fail
    env = KTEnvironment.create!(:name => "batman", :organization => @acme_corporation, :prior => @library)
    env.expects(:systems).returns([stub])
    assert_raises(RuntimeError) do
      env.destroy!
    end
  end

  def test_destroy_env_with_activation_keys_should_fail
    env = KTEnvironment.create!(:name => "batman", :organization => @acme_corporation, :prior => @library)
    env.stubs(:activation_keys).returns([stub])
    assert_raises(RuntimeError) do
      env.destroy!
    end
  end

  def test_destroy_library
    User.current = User.find(users(:admin))
    org = FactoryGirl.create(:katello_organization)
    org.create_library
    org.save!
    env = org.library
    env.destroy
    refute env.destroyed?
  end

  def test_products_are_unique
    provider = create(:katello_provider, organization: @acme_corporation)
    product = create(:katello_product, provider: provider, organization: @acme_corporation)
    2.times do
      create(:katello_repository, product: product, environment: @library,
             content_view_version: @library.default_content_view_version)
    end

    refute_empty @library.products
    assert_equal @library.products.uniq.sort, @library.products.sort
    assert_operator @library.repositories.map(&:product).length, :>, @library.products.length
  end

  def test_content_view_label
    env = @acme_corporation.kt_environments.build(:name => "Test", :label => ContentView::CONTENT_DIR,
                                                  :prior => @library)
    refute env.save
    assert_equal 1, env.errors.size
    assert env.errors.has_key?(:label)
  end
end
end
