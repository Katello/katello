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
    class ContentViewComparison < Search
      attr_accessor :cv_env_ids,
                    :unit_type, # :package, :errata, :puppet_module
                    :offset,
                    :repos,
                    :organization

      def initialize(options)
        super
        self.name  ||= "Content View Comparison"
        self.repos ||= []
        self.rows  ||= []
        build
      end

      def build
        self.cols = build_columns(self.cv_env_ids, self.organization)
        self.rows = build_rows(self.repos, self.cols)
      end

      def build_columns(cv_envs, organization)
        cv_envs.inject({}) do |result, item|
          view = ContentView.readable.find(item[:view_id])
          env = KTEnvironment.content_readable(organization).find(item[:env_id])
          cv_version = view.version(env)
          self.repos += cv_version.repos(env)

          # update columns while we loop through view/env combos
          column = "#{view.id}_#{env.id}"
          result[column] = Column.new(:id => column,
                                      :content => view_compare_name_display(view, env)
                                     )
          result
        end
      end

      def build_rows(repos, cols = [])
        library_repos = repos.map { |repo| repo.library_instance || repo }.uniq
        products = library_repos.map(&:product).uniq

        # build product rows
        rows = build_product_rows(products, cols)

        # build repo and package rows
        rows += build_repo_rows(library_repos, cols)

        # remove the product rows if they have no repos
        rows = rows.reject do |r|
          child_rows = rows.select { |cr| cr.parent_id == r.id }
          r.data_type == "product" && child_rows.empty?
        end

        rows
      end

      def build_product_rows(products, cols = [])
        products.inject([]) do |product_rows, product|
          row = ProductRow.new(:product => product)

          row.cols = cols.inject({}) do |result, (key, _val)|
            result[key] = {:display => " "}
            result
          end

          total = cols.inject(0) do |sum, (key, _col)|
            view_id, env_id = key.split("_")
            # find the product in the view and get the # of units
            env = KTEnvironment.find(env_id)
            version = ContentView.find(view_id).version(env)
            field = "#{unit_type.to_s}_count".to_sym
            count = version.repos(env).select { |r| r.product == product }.map(&field).inject(:+)
            count ? sum + count : sum
          end

          product_rows << row unless total < 1
          product_rows
        end
      end

      # TODO: break up method
      # rubocop:disable MethodLength
      def build_repo_rows(library_repos, cols = [])
        repo_rows = []
        meta_rows = []

        library_repos.each do |library_repo|
          repo_row = RepoRow.new(:repo => library_repo,
                                 :parent_id => "product_#{library_repo.product.id}"
                                )
          view_repos = []

          cols.each do |key, _col|
            view_id = key.split("_").first.to_i
            repo = repos.detect do |r|
              r.content_view.id == view_id && r.library_instance_id == library_repo.id
            end

            if repo
              view_repos << repo
              display = case unit_type
                        when :package
                          repo.package_count
                        when :puppet_module
                          repo.puppet_module_count
                        end

              repo_row.cols[key] = Column.new(:display => display, :id => key)
            end
          end

          search_mode = mode
          if view_repos.length < cv_env_ids.length
            # if the number of cv_envs is greater than the repos to compare
            # it implies that one of the cv_envs does not have this repo
            # which means that there is nothing shared between them
            # and all rows are "not shared" or "unique"
            next if mode == 'shared'
            search_mode = 'all'
          end

          # build the rows
          units = case unit_type
                  when :package
                    Package.legacy_search('', offset, page_size, view_repos.map(&:pulp_id),
                                   [:nvrea_sort, "asc"], search_mode.to_sym)
                  when :puppet_module
                    PuppetModule.legacy_search('', :start => offset, :page_size => page_size,
                                                   :repoids => view_repos.map(&:pulp_id),
                                                   :search_mode => search_mode.to_sym)
                  end

          next if units.empty? # if we don't have units, don't show repo

          repo_rows << repo_row
          repo_rows += build_unit_rows(units, repo_row, cols)

          # add metadata row for Show More link
          total = view_repos.map(&("#{unit_type.to_s}_count".to_sym)).max
          if total > page_size
            meta_row =  MetadataRow.new(:total => total,
                                        :current_count => offset + units.length,
                                        :data => {:repo_id => library_repo.id},
                                        :unique_id => repo_row.id,
                                        :parent_id => repo_row.id
                                       )
            meta_rows << meta_row
          end
        end

        repo_rows + meta_rows
      end

      def build_unit_rows(units, repo_row, cols)
        units.inject([]) do |unit_rows, unit|
          unit_row = UnitRow.new(:unit => unit, :parent_id => repo_row.id)
          cols.each do |key, _col|
            view_id = key.split("_").first.to_i
            repo = repos.detect { |r| r.content_view.id == view_id && r.library_instance_id == repo_row.repo.id }
            if repo && unit.repoids.include?(repo.pulp_id)
              unit_row[:cols][key] = {:id => key}
            end
          end

          unit_rows << unit_row
        end
      end

      def view_compare_name_display(view, env)
        { view_name: view.name,
          view_version: (_("version %s") % view.version(env).version),
          environment_name: env.name,
          type: "content-view-comparison",
          custom: true
        }
      end

      def unit_rows
        rows.select { |row| row.data_type == unit_type.to_s }
      end

      def metadata_rows
        rows.select { |row| row.data_type == "metadata" }
      end
    end
  end
end
