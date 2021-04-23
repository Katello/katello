require 'katello_test_helper'
module Katello
  module Service
    module Pulp3
      module ContentViewVersion
        class ImportableProductsTest < ActiveSupport::TestCase
          include Support::Actions::Fixtures

          it "Fetches the right products to auto create" do
            repo = katello_repositories(:fedora_17_x86_64)
            new_prod_1 = "New-Prod-1"
            new_prod_2 = "New-Prod-2"
            gpg_key = katello_gpg_keys(:fedora_gpg_key)
            metadata = {
              products: {
                new_prod_1 => { label: new_prod_1, name: new_prod_1, gpg_key: { name: gpg_key.name }},
                new_prod_2 => { label: new_prod_2, name: new_prod_2, gpg_key: { name: gpg_key.name }},
                repo.product.label => repo.product.slice(:name, :label)
              },
              gpg_keys: { gpg_key => gpg_key.slice(:name, :content) },
              repositories: {
                "misc-24037": { "label": repo.label,
                                "product": { label: repo.product.label },
                                "redhat": repo.redhat?
                              },
                "hoo-24037": { "label": repo.label,
                               "product": { label: new_prod_1 },
                               "redhat": false
                             },
                "hah-24037": { "label": repo.label,
                               "product": { label: new_prod_2 },
                               "redhat": false
                             }
              }
            }.with_indifferent_access
            helper = Katello::Pulp3::ContentViewVersion::ImportableProducts.
                      new(organization: repo.organization, metadata: metadata)
            helper.generate!
            assert_includes helper.creatable.map { |prod| prod[:product].label }, new_prod_1
            assert_includes helper.creatable.map { |prod| prod[:product].label }, new_prod_2
            refute_includes helper.creatable.map { |prod| prod[:product].label }, repo.product.label
            assert_includes helper.updatable.map { |prod| prod[:product].label }, repo.product.label
            refute_includes helper.updatable.map { |prod| prod[:product].label }, new_prod_1
            refute_nil repo.organization.gpg_keys.find_by(name: gpg_key.name)
          end
        end
      end
    end
  end
end
