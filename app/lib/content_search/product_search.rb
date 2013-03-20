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

module ContentSearch

  class ProductSearch < ContainerSearch
    attr_accessor :product_ids, :view_ids

    def initialize(options)
      super
      self.rows = build_rows
    end

    def build_rows
      rows = []

      views = ContentView.readable(current_organization)
      views = views.where(:id=>@view_ids) unless @view_ids.blank?

      views.each do |view|
        view.all_version_products.collect do |prod|
          cols = {}
          prod.environments.default_view.each do |env|
            cols[env.id] = Cell.new(:hover => container_hover_html(prod, env)) if readable_env_ids.include?(env.id)
          end
          rows << Row.new(:id => "view_#{view.id}_product_#{prod.id}",
                                 :name => prod.name,
                                 :cols => cols,
                                 :data_type => "product",
                                 :value => prod.name,
                                 :parent_id=> "view_#{view.id}"
                                )
        end
      end

      rows
    end

    def products
      @products ||= begin
        if !product_ids.empty?
          products = current_organization.products.readable(current_organization).engineering.where(:id=>product_ids)
        else
          products = current_organization.products.readable(current_organization).engineering
        end

        envs = SearchUtils.search_envs
        if search_mode == :shared
          products = products.select{|p|  (envs - p.environments.default_view).empty? }
        elsif search_mode == :unique
          products = products.select{|p|  !(envs - p.environments.default_view ).empty?}
        end

        products
      end
    end

  end
end
