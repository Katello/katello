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

module ProductsHelper
  def gpg_keys_edit
    keys = {}

    GpgKey.readable(current_organization).each{ |key|
      keys[key.id] = key.name
    }

    keys[""] = ""
    keys["selected"] = @product.gpg_key_id || ""
    return keys.to_json
  end

  def gpg_keys
    GpgKey.readable(current_organization)
  end

  # Objectify the record provided. This will generate a hash containing
  # the record id, list of products and list of repos. It assumes that the
  # record has a 'repositories' relationship.
  def objectify(record)
    repos = Hash.new { |h,k| h[k] = [] }
    record.repositories.each do |repo|
      repos[repo.product.id.to_s] <<  repo.id.to_s
    end

    {
        :id => record.id,
        :products=>record.product_ids,  # :id
        :repos=>repos
    }
  end

  # Retrieve a hash of products that are accessible to the user.
  def get_products
    if @product_hash.nil?
      products = Product.readable(current_organization).sort_by(&:name)
      editable_products = Product.editable(current_organization)
      @product_hash = {}
      products.each do |prod|
        repos = []
        prod.repos(current_organization.library).sort{|a,b| a.name <=> b.name}.each{|repo|
          repos << {:name=>repo.name, :id=>repo.id}
        }
        @product_hash[prod.id] = {:name=>prod.name, :repos=>repos, :id=>prod.id,
                                  :editable=>editable_products.include?(prod)}
      end
    end
    @product_hash
  end
end

