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

class ContentSearch::ProductSearch < ContentSearch::ContainerSearch
  attr_accessor :products

  def initialize(options)
    super
    self.rows = build_rows(self.products)
  end

  def build_rows(products)
    products.collect do |prod|
      cols = {}
      prod.environments.collect do |env|
        cols[env.id] = ContentSearch::Cell.new(:hover => container_hover_html(prod, env)) if env_ids.include?(env.id)
      end
      ContentSearch::Row.new(:id => "product_#{prod.id}",
                             :name => prod.name,
                             :cols => cols,
                             :data_type => "product",
                             :value => prod.name
                            )
    end
  end

end
