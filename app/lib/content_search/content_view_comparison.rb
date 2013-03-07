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
        env = KTEnvironment.content_readable(current_organization).where(:id => item[:env_id]).first
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
      library_repos = repos.map(&:library_instance).uniq
      products = library_repos.map(&:product).uniq
      meta_rows = []

      # build product rows
      content_rows = build_product_rows(products, cols)

      # build repo and package rows
      content_rows += build_repo_rows(library_repos, cols)
    end

    def build_product_rows(products, cols = [])
      products.inject([]) do |product_rows, product|
        row = Row.new(:id => "product_#{product.id}",
                      :name => product.name,
                      :data_type => "product",
                      :cols => {}
                     )

        cols.each do |key, col|
          view_id, env_id = key.split("_")
          # find the product in the view and get the # of packages
          env = KTEnvironment.find(env_id)
          version = ContentView.find(view_id).version(env)
          field = "#{package_type}_count".to_sym
          total = version.repos(env).select{|r| r.product == product}.map(&field).inject(:+)
          row.cols[key] = Column.new(:display => total, :id => key) if total && total > 0
        end
        product_rows << row unless row.cols.empty?
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
          repo = repos.detect {|r| r.content_view.id == view_id && r.library_instance_id == library_repo.id}
          if repo
            view_repos << repo
            display = is_package ? repo.package_count : repo.errata_count
            repo_row.cols[key] = Column.new(:display => display, :id => key)
          end
        end

        # build package or errata rows
        if is_package
          packages = Package.search('', offset, page_size, view_repos.map(&:pulp_id))
        else
          packages = Errata.search('', offset, page_size, :repoids => view_repos.map(&:pulp_id))
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
          if repo && repo.send(is_package ? :packages : :errata).map(&:id).include?(package.id)
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
      version = _("version %s") % view.version(env).version
      {:custom => <<EOS
<span title=\"#{view.name} #{version}\" class=\"one-line-ellipsis tipsify\">#{view.name}</span><span class=\"one-line-ellipsis\">#{env.name}</span>
EOS
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
