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

module PromotionsHelper 
  include ActionView::Helpers::JavaScriptHelper

  include BreadcrumbHelper
  include ChangesetBreadcrumbs
  include ContentBreadcrumbs
  include ErrataHelper

  #returns a proc to generate a url for the env_selector
  def breadcrumb_url_proc
    lambda{|args|
      promotion_path(args[:environment].name,
            :next_env_id=>(args[:next_environment].id if args[:next_environment] and args[:environment].library?))
    }
  end

  def product_filters(prod_or_repo)
    filters = []
    if Product === prod_or_repo
      filters = prod_or_repo.filters
    elsif Repository === prod_or_repo
      filters = prod_or_repo.product.filters
    end
    filters.collect {|f| f.name}
  end

  def repo_filters(prod_or_repo)
    filters = []
    if Product === prod_or_repo
      repos = {}
      prod_or_repo.repos(current_organization.library).each do |repo|
        if repo.filters.count > 0
          repos[repo.name] = repo.filters.collect {|f| f.name}
        end
      end
      return repos
    elsif Repository === prod_or_repo
      filters = prod_or_repo.filters
    end
    filters.collect {|f| f.name}
  end


  def generate_product_repo_filters
    filters = {}
    if @environment == current_organization.library
      @products.each do |prod|
        pid = "product_#{prod.id}"
        filters[pid] = {:product => product_filters(prod),
                                        :repo => repo_filters(prod)}
        filters[pid][:has_filters] = filters[pid][:product].size > 0 || filters[pid][:repo].size > 0
        prod.repos(current_organization.library).each do |repo|
          rid = "repo_#{repo.id}"
          filters[rid] = {:product => product_filters(repo),
                                          :repo => repo_filters(repo)}
          filters[rid][:has_filters] = filters[rid][:product].size > 0 || filters[rid][:repo].size > 0
        end
      end
    end
    escape_javascript(filters.to_json)
  end

end

