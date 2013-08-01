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

module Katello
  module SyncManagementHelper

    def product_id(prod_id)
      "product-#{prod_id}".gsub(".", "_") #jquery treetable doesn't support periods

    end

    def product_child(prod_id)
      "child-of-#{product_id(prod_id)}"
    end

    def set_id(sets)
      product_id(sets.join("-"))
    end

    def parent_set_class(sets)
      product_child(sets.join("-"))
    end

    def repo_id(repo)
      "repo-#{repo.id}"
    end

    def syncable?(product)
      if current_organization
        current_organization.syncable? && !product.orphaned?
      else
        true
      end
    end

    def any_syncable?
      if current_organization
        current_organization.syncable?
      else
        true
      end
    end

    module RepoMethods
      # returns all repos in hash representation with minors and arch children included
      def collect_repos(products, env, include_disabled = false)
        Glue::Pulp::Repos.prepopulate! products, env,[]

        products.map do |prod|
          minor_repos, repos_without_minor = collect_minor(prod.repos(env, include_disabled))
          { :name     => prod.name, :object=> prod, :id => prod.id, :type => "product", :repos => repos_without_minor,
            :children => minors(minor_repos), :organization => prod.organization.name }
        end
      end

      # returns all minors in hash representation with arch children included
      def minors(minor_repos)
        minor_repos.map do |minor, repos|
          { :name => minor, :id => minor, :type => "minor", :children => arches(repos), :repos => [] }
        end
      end

      # returns all archs in hash representation
      def arches(arch_repos)
        collect_arches(arch_repos).map do |arch, repos|
          { :name => arch, :id => arch, :type => "arch", :children => [], :repos => repos }
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
      def pprint_collection coll
        coll.each{|prod|
          Rails.logger.error prod[:name]
          prod[:children].each{|major|
            Rails.logger.error major[:name]
            major[:children].each{|minor|
              Rails.logger.error minor[:name]
              minor[:children].each{|arch|
                Rails.logger.error arch[:repos].length
              }
            }
          }
        }
      end
    end

  end
end
