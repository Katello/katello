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

module SubscriptionsHelper

  def subscriptions_product_helper(product_id)
    cp_product = Resources::Candlepin::Product.get(product_id).first
    product = OpenStruct.new cp_product
    product.cp_id = cp_product['id']
    product
  end

  def subscriptions_system_link_helper(host_id)
    system = System.first(:conditions => { :uuid => host_id })
    link_to system.name, root_path + "systems#panel=system_#{system.id}"
  rescue
    _('System with uuid %s not found') % host_id
  end

  def subscriptions_distributor_link_helper(distributor_id)
    distributor = Distributor.first(:conditions => { :id => distributor_id })
    link_to distributor.name, root_path + "distributors#panel=distributor_#{distributor.id}"
  rescue
    _('Distributor with uuid %s not found') % distributor_id
  end

  def subscriptions_activation_key_link_helper(key)
    link_to key.name, root_path + "activation_keys#panel=activation_key_#{key.id}"
  end

  def subscriptions_manifest_link_helper(status, label = nil)
    if status['webAppPrefix']
      if !status['webAppPrefix'].start_with? 'http'
        url = "http://#{status['webAppPrefix']}"
      else
        url = status['webAppPrefix']
      end

      url += '/' if !url.end_with? '/'
      url += status['upstreamId']
      link_to((label.nil? ? url : label), url, :target => '_blank')
    else
      label.nil? ? status['upstreamId'] : label
    end
  end

  def subscriptions_candlepin_status
    Resources::Candlepin::CandlepinPing.ping
  rescue
    {'rulesVersion'=>'', 'rulesSource'=>''}
  end
end
