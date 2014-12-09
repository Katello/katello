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
  module ProvidersHelper
    include SyncManagementHelper
    include SyncManagementHelper::RepoMethods

    def redhat_repo_tabs
      [
        {:id => :rpms, :name => _('RPMs'), :products => {}},
        {:id => :kickstarts, :name => _('Kickstarts'), :products => {}},
        {:id => :srpms, :name => _('Source RPMs'), :products => {}},
        {:id => :debug, :name => _('Debug RPMs'), :products => {}},
        {:id => :beta, :name => _('Beta'), :products => {}},
        {:id => :isos, :name => _('ISOs'), :products => {}},
        {:id => :docker_images, :name => _('Docker Images'), :products => {}},
        {:id => :other, :name => _('Other'), :products => {}}
      ]
    end

    def redhat_repo_tab(provider, tab_id)
      tabs = {}.with_indifferent_access
      redhat_repo_tabs.each { |tab| tabs[tab[:id]] = tab }

      provider.products.engineering.each do |product|
        product.productContent.each do |prod_content|
          name = prod_content.content.name
          if prod_content.content.type == ::Katello::Repository::CANDLEPIN_DOCKER_TYPE
            key = :docker_images
          elsif name.include?(" Beta ")
            key = :beta
          elsif name.include?("(Source RPMs)")
            key = :srpms
          elsif name.include?("(Debug RPMs)")
            key = :debug
          elsif name.include?("(ISOs)") || name.include?("Source ISOs")
            key = :isos
          elsif name.include?("(RPMs)")
            key = :rpms
          elsif name.include?("(Kickstart)")
            key = :kickstarts
          else
            key = :other
          end
          tabs[key][:products][product.id] ||= []
          tabs[key][:products][product.id] << prod_content
        end
      end
      tabs[tab_id]
    end

    def product_map
      @product_map ||= normalize(collect_repos(
                                     @provider.products.engineering,
                                     current_organization.library))
      @product_map
    end

    # make the structure plain setting it's attributes according to the tree (namely id and class)
    def normalize(children, parent_set = [], data = [], item_type = nil)
      children.sort { |a, b| a[:name] <=> b[:name] }.each do |child|
        new_set = parent_set + [child[:id]]

        item = { :id    => id(new_set),
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
end
