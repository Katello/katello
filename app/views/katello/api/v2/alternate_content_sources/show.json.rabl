object @resource

extends "katello/api/v2/alternate_content_sources/base"

if @resource.respond_to?(:simplified?)
  if @resource.simplified?
    node :products do |acs|
      acs.products.map do |product|
        { id: product.id, organization_id: product.organization.id, name: product.name, label: product.label }
      end
    end
  end
end

node :smart_proxies do |acs|
  acs.smart_proxies.map do |smart_proxy|
    { id: smart_proxy.id, name: smart_proxy.name, url: smart_proxy.url, download_policy: smart_proxy.download_policy }
  end
end