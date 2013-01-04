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

module ProvidersHelper
  include SyncManagementHelper
  include SyncManagementHelper::RepoMethods

  def product_map
    @product_map ||= normalize(collect_repos(
                                    @provider.products.with_repos_only(current_organization.library),
                                    current_organization.library, true))
    @product_map
  end

  def can_enable_repo?
    @provider_editable ||= @provider.editable?
    @provider_editable
  end

  def can_upload_rh_manifest?
    @provider_editable ||= @provider.editable?
    @provider_editable
  end

  def can_edit_rh_provider?
    @provider_editable ||= @provider.editable?
    @provider_editable
  end

  def normalize children, parent_set =[], data = nil, item_type = nil
    data = [] unless data
    children.sort{|a,b| a[:name] <=> b[:name]}.each do |child|
      new_set = parent_set + [child[:id]]
      item =  {:id => set_id(new_set),
               :class => parent_set_class(parent_set),
               :name => child[:name],
                :item => child
               }
      if item_type
        item[:type] = item_type
      elsif child[:type]
        item[:type] = child[:type]
      end
      if item[:type] == "product"
        item[:id] = product_id(child[:id])
      end

      data << item

      if child[:children] && !child[:children].empty?
        normalize(child[:children], new_set, data)
      end
      if child[:repos] && !child[:repos].empty?
        normalize(child[:repos], new_set, data, "repository")
      end
    end
    data
  end

  def name_from_url(url)
    url.sub(@provider.discovery_url, '').gsub('/', ' ').strip
  end

  def label_from_url(url)
    Katello::ModelUtils::labelize(name_from_url(url))
  end

end

