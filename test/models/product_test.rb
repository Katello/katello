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

require File.expand_path("repository_base", File.dirname(__FILE__))

module Katello
  class ProductCreateTest < ActiveSupport::TestCase
    def self.before_suite
      services  = ['Candlepin', 'Pulp', 'ElasticSearch', 'Foreman']
      models    = ['Product']
      disable_glue_layers(services, models, true)
    end

    def setup
      super
      User.current = @admin
      @product = build(:katello_product,
                       :organization => get_organization,
                       :provider => katello_providers(:anonymous)
                      )
      @redhat_product = Product.find(katello_products(:redhat))
      @promoted_product = Product.find(katello_products(:fedora))
    end

    def teardown
      @product.destroy if @product
    end

    def test_redhat?
      assert @redhat_product.redhat?
      refute @product.redhat?
    end

    def test_user_deletable?
      refute @redhat_product.user_deletable?
      assert @product.user_deletable?
      refute @promoted_product.user_deletable?
    end

    def test_create
      assert @product.save
      refute_empty Product.where(:id => @product.id)
    end

    def test_unique_name_per_organization
      @product.save!
      @product2 = build(:katello_product,
                        :organization => @product.organization,
                        :provider => @product.provider,
                        :name => @product.name,
                        :label => 'Another Label')

      refute @product2.valid?
    end

    def test_unique_label_per_organization
      @product.save!
      @product2 = build(:katello_product,
                        :organization => @product.organization,
                        :provider => @product.provider,
                        :name => 'Another Name',
                        :label => @product.label)

      refute @product2.valid?
    end

    def test_syncable_content
      products = Katello::Product.syncable_content
      assert_equal 2, products.length
      products.each { |prod| assert prod.syncable_content? }
    end
  end
end
