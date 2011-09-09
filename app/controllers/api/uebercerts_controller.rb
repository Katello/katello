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

class Api::UebercertsController < Api::ApiController

  before_filter :find_organization, :only => [:show, :create]
  before_filter :find_environment, :only => [:create]
  before_filter :find_ueber_consumer, :only => [:show]

  def create
    existing_ueber_product = ueber_product
    raise HttpErrors::Conflict, _("Ueber certificate has already been generated.") if existing_ueber_product.nil?
    #return regenerate_ueber_certificate(existing_ueber_product[:id]) unless existing_ueber_product.nil?
    render :json => generate_ueber_certificate[:certificates].first[:cert]
  end

  def show
    render :json => Candlepin::Consumer.entitlements(@ueber_consumer.uuid).first[:certificates].first[:cert]
  end

  def generate_ueber_certificate
    ueber_product = Candlepin::Product.create({
      :name => "#{@organization.name}_ueber",
      :multiplier => 1,
      :attributes => []
    })

    ueber_content = Candlepin::Content.create({
      :name => "ueber_content",
      :contentUrl => "/#{@organization.name}",
      :gpgUrl => "",
      :type => "yum",
      :label => "#{ueber_product[:id]}_ueber_content",
      :vendor => "Custom"
    })

    Candlepin::Product.add_content(ueber_product[:id], ueber_content[:id], true)

    subscription = {
      'startDate' => Date.today,
      'endDate'   => Date.today + 10950, # 100 years from now
      'quantity'  =>  1,
      'accountNumber' => '',
      'product' => { 'id' => ueber_product[:id] },
      'providedProducts' => [],
      'contractNumber' => ''
    }
    Candlepin::Subscription.create_for_owner @organization.cp_key, subscription
    Candlepin::Subscription.refresh_for_owner @organization.cp_key

    ueber_pool = Candlepin::Owner.pools(@organization.cp_key, {:product => ueber_product[:id]})

    ueber_consumer = System.create(
        :name => "ueber_consumer",
        :environment => @environment,
        :cp_type => "system",
        :facts => {"distribution.name" => "Fedora"}
    )
    Candlepin::Consumer.consume_entitlement(ueber_consumer.uuid, ueber_pool.first[:id], 1)
  end

  def regenerate_ueber_certificate(product_id)
    Candlepin::Entitlement.regenerate_entitlement_certificates_for_product(product_id)
  end

  def ueber_product
    Candlepin::Product.get.select {|p| p[:name] == "#{@organization.name}_ueber"}
  end

  def find_ueber_consumer
    @ueber_consumer = System.find_by_name("ueber_consumer")
    raise HttpErrors::NotFound, _("Couldn't find ueber consumer for organization '#{params[:organization_id]}'. Try to generate ueber-certificate.") if @ueber_consumer.nil?
    @ueber_consumer
  end

  def find_environment
    raise HttpErrors::BadRequest, _("Organization #{@organization.name} has 'Locker' environment only. Please create an environment.") if @organization.environments.empty?
    @environment = @organization.environments.first
  end
end