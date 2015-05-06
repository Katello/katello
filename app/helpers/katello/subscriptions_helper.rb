module Katello
  module SubscriptionsHelper
    def subscriptions_product_helper(product_id)
      cp_product = Resources::Candlepin::Product.get(product_id).first
      product = OpenStruct.new cp_product
      product.cp_id = cp_product['id']
      product
    end

    def subscriptions_manifest_link_helper(status, label = nil)
      if status['webAppPrefix']
        if !status['webAppPrefix'].start_with? 'http'
          url = "http://#{status['webAppPrefix']}"
        else
          url = status['webAppPrefix']
        end

        url += '/' unless url.end_with? '/'
        url += status['upstreamId']
        link_to((label.nil? ? url : label), url, :target => '_blank')
      else
        label.nil? ? status['upstreamId'] : label
      end
    end

    def subscriptions_candlepin_status
      Resources::Candlepin::CandlepinPing.ping
    rescue
      {'rulesVersion' => '', 'rulesSource' => ''}
    end
  end
end
