#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

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

  def syncable?
    return current_organization.syncable?
  end

  module RepoMethods
    def collect_repos products, env, include_disabled = false
      Glue::Pulp::Repos.prepopulate! products, env,[]
      list = []
      products.each{|prod|
        minors = []
        release, non_release = collect_minor(prod.repos(current_organization.library, include_disabled))
        release.each{|minor, minor_repos|
          arches = []
          collect_arches(minor_repos).each{|arch, arch_repos|
            arches << {:name=>arch, :id=>arch, :type=>"arch", :children=>[], :repos=>arch_repos}
          }
          minors << {:name=>minor, :id=>minor, :type=>"minor", :children=>arches, :repos=>[]}
        }

        list << {:name=>prod.name, :id=>prod.id, :type=>"product",  :repos=>non_release, :children=>minors}
      }
      list
    end


    def collect_minor repos
      minors = {}
      empty = []
      repos.each{|r|
        if r.minor
          minors[r.minor] ||= []
          minors[r.minor] << r
        else
          empty << r
        end
      }
      [minors, empty]
    end

    def collect_arches repos
      arches = {}
      repos.each{|r|
        arches[r.arch] ||= [ ]
        arches[r.arch] << r
      }
      arches
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
