# encoding: utf-8
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

require 'test_helper'

class KTEnvironmentTestBase < ActiveSupport::TestCase

  extend ActiveRecord::TestFixtures

  fixtures :all

  def self.before_suite
    services  = ['Candlepin', 'Pulp', 'ElasticSearch', 'Foreman']
    models    = ['Repository', 'KTEnvironment', 'ContentView',
                 'ContentViewEnvironment', 'Organization', 'Product',
                 'Provider']
    disable_glue_layers(services, models, true)
  end

  def setup
    @library              = KTEnvironment.find(environments(:library).id)
    @dev                  = KTEnvironment.find(environments(:dev).id)
    @staging              = KTEnvironment.find(environments(:staging).id)
    @acme_corporation     = Organization.find(organizations(:acme_corporation).id)
  end

end


class KTEnvironmentTest < KTEnvironmentTestBase

  def test_create_and_validate_default_content_view
    env = KTEnvironment.create(:organization=>@acme_corporation, :name=>"SomeEnv", :prior=>@library)
    assert_nil env.default_content_view
    assert_nil env.default_content_view_version
  end

  def test_destroy_content_view_environment
    env = @staging
    cve = env.content_views.first.content_view_environments.where(:environment_id=>env.id).first
    cve_cp_id = cve.cp_id
    env.destroy
    assert_empty ContentViewEnvironment.where(:cp_id=>cve_cp_id)
  end

  def test_destroy_library
    org = FactoryGirl.create(:organization)
    env = org.library
    env.destroy
    refute env.destroyed?
  end

  def test_products_are_unique
    provider = create(:provider, organization: @acme_corporation)
    product = create(:product, provider: provider)
    2.times do
      create(:repository, product: product, environment: @library,
             content_view_version: @library.default_content_view_version)
    end

    refute_empty @library.products
    assert_equal @library.products.uniq.sort, @library.products.sort
    assert_operator @library.repositories.map(&:product).length, :>, @library.products.length
  end
end
