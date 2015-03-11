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

module Katello
  module ContentSearch
    class ProductSearch < ContainerSearch
      attr_accessor :products, :views, :organization

      def initialize(options)
        super
        self.rows = build_rows
      end

      def build_rows
        rows = []
        @views.each do |view|
          filtered_products(view).each do |prod|
            cols = {}
            prod.environments_for_view(view).each do |env|
              if readable_env_ids(organization).include?(env.id)
                cols[env.id] = Cell.new(:hover => lambda { container_hover_html(prod, env, view) },
                                        :hover_details => lambda { container_hover_html(prod, env, view, true) })
              end
            end
            rows << Row.new(:id => "view_#{view.id}_product_#{prod.id}",
                            :name => prod.name,
                            :cols => cols,
                            :data_type => "product",
                            :value => prod.name,
                            :parent_id => "view_#{view.id}",
                            :object_id => view.id
                                  )
          end
        end

        rows
      end

      def filtered_products(view)
        filtered = products & view.all_version_products
        envs = SearchUtils.search_envs(mode)
        if mode == 'shared'
          filtered = filtered.select { |p|  (envs - p.environments_for_view(view)).empty? }
        elsif mode == 'unique'
          filtered = filtered.select { |p|  !(envs - p.environments_for_view(view)).empty? }
        end
        filtered
      end
    end
  end
end
