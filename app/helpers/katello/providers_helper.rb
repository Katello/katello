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
        {:id => :docker_manifests, :name => _('Docker Manifests'), :products => {}},
        {:id => :other, :name => _('Other'), :products => {}}
      ]
    end

    def redhat_repo_tab(provider, tab_id)
      tabs = {}.with_indifferent_access
      redhat_repo_tabs.each { |tab| tabs[tab[:id]] = tab }

      provider.products.each do |product|
        product.productContent.each do |prod_content|
          name = prod_content.content.name
          if prod_content.content.type == ::Katello::Repository::CANDLEPIN_DOCKER_TYPE
            key = :docker_manifests
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
                                     @provider.products,
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
      url.sub(provider.discovery_url, '').tr('/', ' ').strip
    end

    def label_from_url(provider, url)
      Util::Model.labelize(name_from_url(provider, url))
    end
  end
end
