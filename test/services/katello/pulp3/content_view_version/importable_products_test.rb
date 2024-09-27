require 'katello_test_helper'

module Katello
  module Service
    module Pulp3
      module ContentViewVersion
        class ImportableProductsTest < ActiveSupport::TestCase
          it "Fetches the right products to auto create" do
            repo = katello_repositories(:fedora_17_x86_64)
            new_prod_1 = "New-Prod-1"
            new_prod_2 = "New-Prod-2"
            gpg_key = katello_gpg_keys(:fedora_gpg_key)

            metadata_gpg_key = stub('metadata gpg key', name: gpg_key.name)

            metadata_products = [
              stub(label: new_prod_1, name: new_prod_1, description: 'fake', redhat: false, gpg_key: metadata_gpg_key),
              stub(label: new_prod_2, name: new_prod_2, description: 'fake', redhat: false, gpg_key: nil),
              stub(label: repo.product.label, name: repo.product.name, description: repo.product.description, redhat: false, gpg_key: metadata_gpg_key),
            ]

            helper = Katello::Pulp3::ContentViewVersion::ImportableProducts.new(
              organization: repo.organization,
              metadata_products: metadata_products
            )
            helper.generate!

            assert_includes helper.creatable.map { |prod| prod[:product].label }, new_prod_1
            assert_includes helper.creatable.map { |prod| prod[:product].label }, new_prod_2
            refute_includes helper.creatable.map { |prod| prod[:product].label }, repo.product.label
            assert_includes helper.updatable.map { |prod| prod[:product].label }, repo.product.label
            refute_includes helper.updatable.map { |prod| prod[:product].label }, new_prod_1

            assert_equal gpg_key.id, helper.creatable.first[:product].gpg_key_id
            assert_nil helper.creatable.second[:product].gpg_key_id
            assert_equal gpg_key.id, helper.updatable.first[:options][:gpg_key_id]
          end

          it "Fetches the right product name to auto create" do
            repo = katello_repositories(:fedora_17_x86_64)
            gpg_key = katello_gpg_keys(:fedora_gpg_key)

            metadata_gpg_key = stub('metadata gpg key', name: gpg_key.name)
            label = "#{repo.product.label}-f000"

            metadata_products = [
              stub(label: label, name: repo.product.name, description: repo.product.description, redhat: false, gpg_key: metadata_gpg_key),
            ]

            helper = Katello::Pulp3::ContentViewVersion::ImportableProducts.new(
              organization: repo.organization,
              metadata_products: metadata_products
            )
            helper.generate!

            assert_includes helper.creatable.map { |prod| prod[:product].label }, label
            assert_includes helper.creatable.map { |prod| prod[:product].name }, "#{repo.product.name} 1"
          end
        end
      end
    end
  end
end
