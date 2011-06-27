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
  #include Authorization
  include LazyAccessor

  #has_many :products
  belongs_to :environment, {:class_name => "KPEnvironment"}

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :environment_id

  has_and_belongs_to_many :products

  attr_accessor :host_group, :group_parameters
  lazy_accessor :packages, :initializer => lambda { init_packages }, :unless => lambda { false } #set 'unless' to false -> load also for new records
  lazy_accessor :errata,   :initializer => lambda { init_errata },   :unless => lambda { false }
  lazy_accessor :group_parameters, :initializer => lambda { init_group_parameters }, :unless => lambda { false }

  before_validation :attrs_to_json
  before_save :update_revision


  def init_packages
    packages = ActiveSupport::JSON.decode((self.packages_json or "[]"))
    packages.collect do |p|
      package = self.find_package_in_env(p)
      raise Errors::TemplateContentException.new("Package #{p} not found in this environment.") if package == nil
      package
    end
  end


  def init_errata
    errata = ActiveSupport::JSON.decode((self.errata_json or "[]"))
    errata.collect do |e|
      erratum = self.find_errata_in_env(e)
      raise Errors::TemplateContentException.new("Errata #{e} not found in this environment.") if erratum == nil
      erratum
    end
  end


  def init_products
    products = ActiveSupport::JSON.decode((self.products_json or "[]"))
    products.collect do |p|
      product = self.environment.products.find_by_name(p)
      raise Errors::TemplateContentException.new("Product #{p} not found in this environment.") if product == nil
      product
    end
  end


  def init_group_parameters
    ActiveSupport::JSON.decode((self.group_parameters_json or "{}"))
  end


  #TODO: comment
  def content_valid?
    self.packages
    self.errata
    self.host_group
    self.group_parameters
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

    self.host_group_name = json["host_group_name"] if not json["host_group_name"].nil?

    if not json["group_parameters"].nil?
      json["group_parameters"].each_pair do |k,v|
        self.group_parameters[k] = v
      end
    end

  end


  def string_export
    #TODO: fix after all changes
    tpl = {
      :revision => self.revision,
      :packages => ActiveSupport::JSON.decode(self.packages_json),
      :errata => ActiveSupport::JSON.decode(self.errata_json),
      :products => ActiveSupport::JSON.decode(self.products_json),
      :group_parameters => ActiveSupport::JSON.decode(self.group_parameters_json)
    }
    tpl.to_json
  end


  def add_package package_name
    package = self.find_package_in_env(package_name)
    if package == nil
      raise Errors::TemplateContentException.new("Package #{package_name} not found in this environment.")
    end
    self.packages = (self.packages << package).uniq
  end


  def remove_package package_name
    idx = self.packages.map(&:name).index(package_name)
    self.packages.delete_at(idx) if not idx.nil?
  end


  def add_erratum erratum_id
    erratum = self.find_errata_in_env(erratum_id)
    if erratum == nil
      raise Errors::TemplateContentException.new("Errata #{erratum_id} not found in this environment.")
    end
    self.errata = (self.errata << erratum).uniq
  end


  def remove_erratum erratum_id
    idx = self.errata.map(&:id).index(erratum_id)
    self.errata.delete_at(idx) if not idx.nil?
  end


  def add_product product_name
    product = self.environment.products.find_by_name(product_name)
    if product == nil
      raise Errors::TemplateContentException.new("Product #{product_name} not found in this environment.")
    end
    self.products = (self.products << product).uniq
  end


  def remove_product product_name
    idx = self.products.map(&:name).index(product_name)
    self.products.delete_at(idx) if not idx.nil?
  end


  def to_json(options={})
     super(options.merge({
        :methods => [:products,
                     :packages,
                     :errata,
                     :group_parameters]
        })
     )
  end


  protected


  def attrs_to_json
    self.products_json = self.products.map(&:name).to_json
    self.errata_json   = self.errata.map(&:id).to_json
    self.packages_json = self.packages.map(&:name).to_json
    self.group_parameters_json = self.group_parameters.to_json
  end


  def update_revision

    self.revision = 1 if self.revision.nil?

    #increase revision number only on content attribute change
    if not self.new_record?
      content_changes = @changed_attributes.select {|k, v| (k!=:name && k!=:description && k!=:revision) }
      self.revision += 1 if not content_changes.empty?
    end
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




end
