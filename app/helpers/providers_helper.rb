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

module ProvidersHelper
  include SyncManagementHelper
  include SyncManagementHelper::RepoMethods

  def redhat_repo_tabs(provider)
    tabs = {
        :rpms => {:id => :rpms, :name => _('RPMs'), :products => {}, :order => 1},
        :srpms => {:id => :srpms, :name => _('Source RPMs'), :products => {}, :order => 2},
        :debug => {:id => :debug, :name => _('Debug RPMs'), :products => {}, :order => 3},
        :beta => {:id => :beta, :name => _('Beta'), :products => {}, :order => 4},
        :isos => {:id => :isos, :name => _('ISOs'), :products => {}, :order => 5},
        :other => {:id => :other, :name => _('Other'), :products => {}, :order => 6}
    }
    provider.products.engineering.each do |product|
      product.productContent.each do |prod_content|
        name = prod_content.content.name
        if name.include?(" Beta ")
          key = :beta
        elsif name.include?("(Source RPMs)")
          key = :srpms
        elsif name.include?("(Debug RPMs)")
          key = :debug
        elsif name.include?("(ISOs)") || name.include?("Source ISOs")
          key = :isos
        elsif name.include?("(RPMs)")
          key = :rpms
        else
          key = :other
        end
        tabs[key][:products][product.id] ||= []
        tabs[key][:products][product.id] << prod_content
      end
    end
    tabs.values.sort_by { |h| h[:order] }
  end

  def product_map
    @product_map ||= normalize(collect_repos(
                                   @provider.products.engineering,
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

  # make the structure plain setting it's attributes according to the tree (namely id and class)
  def normalize(children, parent_set = [], data = [], item_type = nil)
    children.sort { |a, b| a[:name] <=> b[:name] }.each do |child|
      new_set = parent_set + [child[:id]]

      item = { :id    => set_id(new_set),
               :class => parent_set_class(parent_set),
               :name  => child[:name],
               :item  => child,
               :type  => item_type || child[:type]
      }
      item[:id] = product_id(child[:id]) if item[:type] == "product"

      data << item

      normalize(child[:children], new_set, data) if child[:children].present?
      normalize(child[:repos], new_set, data, "repository") if child[:repos].present?
    end
    data
  end

  def name_from_url(provider, url)
    url.sub(provider.discovery_url, '').gsub('/', ' ').strip
  end

  def label_from_url(provider, url)
    Util::Model.labelize(name_from_url(provider, url))
  end

end

