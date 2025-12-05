module Katello
  module SyncManagementHelper
    def product_id(prod_id)
      "product-#{prod_id}".tr(".", "_") #jquery treetable doesn't support periods
    end

    def product_child(prod_id)
      "child-of-#{product_id(prod_id)}"
    end

    def id(sets)
      product_id(sets.join("-"))
    end

    def parent_set_class(sets)
      product_child(sets.join("-"))
    end

    def repo_id(repo)
      "repo-#{repo.id}"
    end

    def syncable?(product)
      product.syncable? && !product.orphaned? && product.syncable_content?
    end

    def any_syncable?
      Product.syncable? && current_organization_object.syncable_content?
    end

    module RepoMethods
      # Format a repository as a hash for the API
      def format_repo(repo)
        {
          :id => repo.id,
          :name => repo.name,
          :type => "repo",
        }
      end

      # Recursively check if a node has any repositories
      def repos?(node)
        return true if node[:repos].present? && node[:repos].any?
        return false if node[:children].blank?
        node[:children].any? { |child| repos?(child) }
      end

      # Filter out nodes with no repositories
      def filter_empty_nodes(nodes)
        nodes.select { |node| repos?(node) }.map do |node|
          if node[:children].present?
            node.merge(:children => filter_empty_nodes(node[:children]))
          else
            node
          end
        end
      end

      # returns all repos in hash representation with minors and arch children included
      def collect_repos(products, env, include_feedless = true)
        products.map do |prod|
          minor_repos, repos_without_minor = collect_minor(prod.repos(env, nil, include_feedless))
          { :name => prod.name, :object => prod, :id => prod.id, :type => "product",
            :repos => repos_without_minor.map { |r| format_repo(r) },
            :children => minors(minor_repos, prod.id), :organization => prod.organization.name }
        end
      end

      # returns all minors in hash representation with arch children included
      def minors(minor_repos, product_id)
        minor_repos.map do |minor, repos|
          minor_id = "#{product_id}-#{minor}"
          { :name => minor, :id => minor_id, :type => "minor",
            :children => arches(repos, minor_id), :repos => [] }
        end
      end

      # returns all archs in hash representation
      def arches(arch_repos, parent_id)
        collect_arches(arch_repos).map do |arch, repos|
          arch_id = "#{parent_id}-#{arch}"
          { :name => arch, :id => arch_id, :type => "arch", :children => [],
            :repos => repos.map { |r| format_repo(r) } }
        end
      end

      # converts array of repositories to hash using minor as key
      #
      # repositories having nil minor are returned as a second variable, if none such is present,
      # empty array is returned
      #
      # collect_arches [<#repo1 minor:1>, <#repo2 minor:2>, <#repo3 minor:nil>] # =>
      #   [{'1' => [<#repo1>], '2' => <#repo2>]}, [#<repo3>]]
      def collect_minor(repos)
        result               = repos.group_by(&:minor)
        result_without_minor = result.delete(nil)
        [result, result_without_minor || []]
      end

      # converts array of repositories to hash using architecture as key
      #
      # collect_arches [<#repo1 arch:i386>, <#repo2 arch:i386>, <#repo3 arch:x86_64>] # =>
      #   {'i386' => [<#repo1>, <#repo2>], 'x86_64' => [#<repo3>]}
      def collect_arches(repos)
        repos.group_by(&:arch)
      end

      #Used for debugging collect_repos output
      def pprint_collection(coll)
        coll.each do |prod|
          Rails.logger.error prod[:name]
          prod[:children].each do |major|
            Rails.logger.error major[:name]
            major[:children].each do |minor|
              Rails.logger.error minor[:name]
              minor[:children].each do |arch|
                Rails.logger.error arch[:repos].length
              end
            end
          end
        end
      end
    end

    def repos?(product)
      if product[:children].present?
        product[:children].collect do |child|
          repos?(child)
        end
      else
        product[:repos].length > 0
      end
    end
  end
end
