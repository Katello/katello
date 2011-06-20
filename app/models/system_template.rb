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


class SystemTemplate < ActiveRecord::Base
  #has_many :products
  belongs_to :environment, {:class_name => "KPEnvironment"}

  validates_presence_of :name

  attr_accessor :packages, :errata, :products, :host_group, :kickstart_attrs

  before_validation :attrs_to_json

  def initialize attrs
    super(attrs)
  end


  def packages
    return @packages if not @packages.nil?

    packages = ActiveSupport::JSON.decode((self.packages_json or "[]"))
    @packages = packages.collect do |p|
      package = self.find_package_in_env(p)
      if package == nil
        raise Errors::TemplateContentException.new("Package #{p} not found in this environment.")
      end
      package
    end
  end


  def errata
    return @errata if not @errata.nil?

    errata = ActiveSupport::JSON.decode((self.errata_json or "[]"))
    @errata = errata.collect do |e|
      erratum = self.find_errata_in_env(e)
      if erratum == nil
        raise Errors::TemplateContentException.new("Errata #{e} not found in this environment.")
      end
      erratum
    end
  end


  def products
    return @products if not @products.nil?

    products = ActiveSupport::JSON.decode((self.products_json or "[]"))
    @products = products.collect do |p|
      product = self.environment.products.find_by_name(p)
      if product == nil
        raise Errors::TemplateContentException.new("Product #{p} not found in this environment.")
      end
      product
    end
  end


  def host_group
    return @host_group if not @host_group.nil?
    @host_group = ActiveSupport::JSON.decode((self.host_group_json or "{}"))
  end


  def kickstart_attrs
    return @kickstart_attrs if not @kickstart_attrs.nil?
    @kickstart_attrs = ActiveSupport::JSON.decode((self.kickstart_attrs_json or "{}"))
  end


  #TODO: comment, do we really need this function?
  def content_valid?
    self.packages
    self.errata
    self.host_group
    self.kickstart_attrs
    self.packages

    return true
  rescue

    return false
  end


  def import tpl_file_path
    Rails.logger.info "Importing into template #{name}"

    file = File.open(tpl_file_path,"r")
    content = file.read
    self.string_import content

  ensure
    file.close
  end


  def string_import content
    json = ActiveSupport::JSON.decode(content)

    self.revision = json["revision"]
    json["products"].collect do |p| self.add_product(p) end if not json["products"].nil?
    json["packages"].collect do |p| self.add_package(p) end if not json["packages"].nil?
    json["errata"].collect   do |e| self.add_erratum(e) end if not json["errata"].nil?

    self.host_group = json["host_group"] if not json["host_group"].nil?
    
    if not json["kickstart_attributes"].nil?
      json["kickstart_attributes"].each_pair do |k,v|
        self.kickstart_attrs[k] = v
      end
    end

  end


  def string_export
    tpl = {
      :revision => self.revision,
      :packages => ActiveSupport::JSON.decode(self.packages_json),
      :errata => ActiveSupport::JSON.decode(self.errata_json),
      :products => ActiveSupport::JSON.decode(self.products_json),
      :host_group => ActiveSupport::JSON.decode(self.host_group_json),
      :kickstart_attrs => ActiveSupport::JSON.decode(self.kickstart_attrs_json)
    }
    tpl.to_json
  end


  def add_package package_name
      package = self.find_package_in_env(package_name)
      if package == nil
        raise Errors::TemplateContentException.new("Package #{package_name} not found in this environment.")
      end
      self.packages << package
  end


  def add_erratum erratum_id
    erratum = self.find_errata_in_env(erratum_id)
    if erratum == nil
      raise Errors::TemplateContentException.new("Errata #{erratum_id} not found in this environment.")
    end
    self.errata << erratum
  end


  def add_product product_name
    product = self.environment.products.find_by_name(product_name)
    if product == nil
      raise Errors::TemplateContentException.new("Product #{product_name} not found in this environment.")
    end
    self.products << product
  end


  def to_json(options={})
     super(options.merge({
        :methods => [:products,
                     :packages,
                     :errata,
                     :host_group,
                     :kickstart_attrs]
        })
     )
  end

  protected

  def packages_json= attrs
    @attributes['packages_json'] = attrs
  end

  def errata_json= attrs
    @attributes['errata_json'] = attrs
  end


  def products_json= attrs
    @attributes['products_json'] = attrs
  end


  def host_groups_json= attrs
    @attributes['host_groups_json'] = attrs
  end


  def kickstart_attrs_json= attrs
    @attributes['kickstart_attrs_json'] = attrs
  end


  def find_errata_in_env(erratum_id)

    self.products.each do |product|
      product.repos(self.environment).each do |repo|
        #search for errata in all repos in a product
        idx = repo.errata.index do |e| e.id == erratum_id end
        return repo.errata[idx] if idx != nil

      end
    end
    nil
  end


  def find_package_in_env(package_name)

    self.products.each do |product|
      product.repos(self.environment).each do |repo|
        #search for errata in all repos in a product
        idx = repo.packages.index do |p| p.name == package_name end
        return repo.packages[idx] if idx != nil

      end
    end
    nil
  end


  def attrs_to_json
    self.products_json = self.products.map(&:name).to_json
    self.errata_json   = self.errata.map(&:id).to_json
    self.packages_json = self.packages.map(&:name).to_json
    self.kickstart_attrs_json = self.kickstart_attrs.to_json
    self.host_group_json      = self.host_group.to_json
  end

end
