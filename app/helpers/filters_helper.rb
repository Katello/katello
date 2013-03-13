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

module FiltersHelper

  # Objectify the record provided. This will generate a hash containing
  # the record id, list of products and list of repos. It assumes that the
  # record has 'products' and 'repositories' relationships.
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
  # This will be determined from the filter record provided in the options.
  def get_products(options)
    if @product_hash.nil?
      @product_hash = {}
      options[:record].content_view_definition.resulting_products.sort_by(&:name).each do |prod|
        @product_hash[prod.id] = {:id => prod.id, :name => prod.name, :editable => true, :repos => []}
      end
      options[:record].content_view_definition.repos.sort_by(&:name).each do |repo|
        @product_hash[repo.product_id][:repos].push({:id => repo.id, :name => repo.name})
      end
    end
    @product_hash
  end

end
