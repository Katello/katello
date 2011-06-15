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

  attr_reader :packages, :errata, :products, :host_group, :kickstart_attrs


  def initialize attrs
    super(attrs)
  end


  def packages_json= attrs
    @packages = nil
    @attributes['packages_json'] = attrs
  end

  def errata_json= attrs
    @errata = nil
    @attributes['errata_json'] = attrs
  end

  def products_json= attrs
    @products = nil
    @attributes['products_json'] = attrs
  end


  def packages
    return @packages if not @packages.nil?

    packages = ActiveSupport::JSON.decode(self.packages_json)
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

    errata = ActiveSupport::JSON.decode(self.errata_json)
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

    products = ActiveSupport::JSON.decode(self.products_json)
    @products = products.collect do |p|
      product = self.environment.products.find_by_name(p)
      if product == nil
        raise Errors::TemplateContentException.new("Product #{p} not found in this environment.")
      end
      product
    end
  end


  def host_group
    ActiveSupport::JSON.decode(self.host_group_json)
  end


  def kickstart_attrs
    ActiveSupport::JSON.decode(self.kickstart_attrs_json)
  end


  #TODO: comment
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
    json = ActiveSupport::JSON.decode(content)

    self.revision      = json["revision"]
    self.packages_json = (json["packages"] or []).to_json
    self.errata_json   = (json["errata"] or []).to_json
    self.products_json = (json["products"] or []).to_json
    self.host_group_json      = (json["host_group"] or {}).to_json
    self.kickstart_attrs_json = (json["kickstart_attributes"] or []).to_json

    if not self.content_valid?
      raise Errors::TemplateContentException.new("Specified template content not found in this environment.")
    end

  ensure
    file.close
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
end
