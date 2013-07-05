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

  class ContentViewComparison < Search
    attr_accessor :cv_env_ids, :is_package

    def initialize(options)
      super
      self.name  ||= "Content View Comparison"
      self.repos ||= []
      self.rows  ||= []
      build
    end

    def build
      self.cols = build_columns(self.cv_env_ids)
      self.rows = build_rows(self.is_package, self.repos, self.cols)
    end

    def build_columns(cv_envs)
      cv_envs.inject({}) do |result, item|
        view = ContentView.readable(current_organization).find(item[:view_id])
        env = KTEnvironment.content_readable(current_organization).find(item[:env_id])
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

    def build_rows(is_package, repos, cols = [])
      library_repos = repos.map{|repo| repo.library_instance || repo}.uniq
      products = library_repos.map(&:product).uniq
      meta_rows = []

      # build product rows
      content_rows = build_product_rows(products, cols)

      # build repo and package rows
      content_rows += build_repo_rows(library_repos, cols)

      # remove the product rows if they have no repos
      content_rows = content_rows.reject do |r|
        child_rows = content_rows.select {|cr| cr.parent_id == r.id}
        r.data_type == "product" && child_rows.empty?
      end

      content_rows
    end

    def build_product_rows(products, cols = [])
      products.inject([]) do |product_rows, product|
        row = ProductRow.new(:product => product)

        row.cols = cols.inject({}) do |result, (key, val)|
          result[key] = {:display => " "}
          result
        end

        total = cols.inject(0) do |total, (key, col)|
          view_id, env_id = key.split("_")
          # find the product in the view and get the # of packages
          env = KTEnvironment.find(env_id)
          version = ContentView.find(view_id).version(env)
          field = "#{package_type}_count".to_sym
          count = version.repos(env).select{|r| r.product == product}.map(&field).inject(:+)
          count ? total + count : total
        end

        product_rows << row unless total < 1
        product_rows
      end
    end

    def build_repo_rows(library_repos, cols = [])
      repo_rows = []
      meta_rows = []

      library_repos.each do |library_repo|
        repo_row = RepoRow.new(:repo => library_repo,
                               :parent_id => "product_#{library_repo.product.id}"
                              )
        view_repos = []

        cols.each do |key, col|
          view_id = key.split("_").first.to_i
          repo = repos.detect do |r|
            r.content_view.id == view_id && r.library_instance_id == library_repo.id
          end
          if repo
            view_repos << repo
            display = is_package ? repo.package_count : repo.errata_count
            repo_row.cols[key] = Column.new(:display => display, :id => key)
          end
        end

        package_search_mode = mode
        if view_repos.length < cv_env_ids.length
          # if the number of cv_envs is greater than the repos to compare
          # it implies that one of the cv_envs does not have this repo
          # which means that there is nothing shared between them
          # and all rows are "not shared" or "unique"
          next if mode == :shared
          package_search_mode = :all
        end

        # build package or errata rows
        if is_package
          packages = Package.search('', offset, page_size, view_repos.map(&:pulp_id),
                                    [:nvrea_sort, "ASC"], package_search_mode)
        else
          packages = Errata.search('', offset, page_size,
                                   :repoids => view_repos.map(&:pulp_id),
                                   :search_mode => package_search_mode)
        end

        next if packages.empty? # if we don't have packages/errata, don't show repo


        repo_rows << repo_row
        repo_rows += build_package_rows(packages, repo_row, cols)

        # add metadata row for Show More link
        total = view_repos.map(&("#{package_type}_count".to_sym)).max
        if total > page_size
          meta_row =  MetadataRow.new(:total => total,
                                      :current_count => offset + packages.length,
                                      :data => {:repo_id=>library_repo.id},
                                      :unique_id => repo_row.id,
                                      :parent_id => repo_row.id
                                     )
          meta_rows << meta_row
        end
      end

      repo_rows + meta_rows
    end

    def build_package_rows(packages, repo_row, cols)
      packages.inject([]) do |package_rows, package|
        package_row = PackageRow.new(:package => package, :parent_id => repo_row.id)
        cols.each do |key, col|
          view_id = key.split("_").first.to_i
          repo = repos.detect {|r| r.content_view.id == view_id && r.library_instance_id == repo_row.repo.id}
          if package.repoids.include?(repo.pulp_id)# repo && repo.send(is_package ? :packages : :errata).map(&:id).include?(package.id)
            package_row[:cols][key] = {:id => key}
          end
        end

        package_rows << package_row
      end
    end

    def repos
      @repos
    end

    def repos=(repos = [])
      @repos = repos
    end

    def view_compare_name_display(view, env)
      { view_name: view.name,
        view_version: (_("version %s") % view.version(env).version),
        environment_name: env.name,
        type: "content-view-comparison",
        custom: true
      }
    end

    def package_type
      is_package ? 'package' : 'errata'
    end

    def package_rows
      rows.select{|row| row.data_type == package_type}
    end

    def metadata_rows
      rows.select{|row| row.data_type == "metadata"}
    end
  end

end
