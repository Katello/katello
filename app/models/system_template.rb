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

  has_and_belongs_to_many :products, :uniq => true
  has_many :errata,   :class_name => "SystemTemplateErratum", :inverse_of => :system_template
  has_many :packages, :class_name => "SystemTemplatePackage", :inverse_of => :system_template

  attr_accessor :host_group
  lazy_accessor :group_parameters, :initializer => lambda { init_group_parameters }, :unless => lambda { false }

  before_validation :attrs_to_json
  before_save :update_revision


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

    self.name = json["name"] if not json["name"].nil?

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
      :packages => self.packages.map(&:package_name),
      :errata   => self.errata.map(&:erratum_id),
      :products => self.products.map(&:name),
      :group_parameters => ActiveSupport::JSON.decode(self.group_parameters_json)
    }
    tpl.to_json
  end


  def add_package package_name
    package = SystemTemplatePackage.new(:package_name => package_name)
    self.packages << package
  end


  def remove_package package_name
    package = self.packages.find(:first, :conditions => {:package_name => package_name})
    package.destroy
  end


  def add_erratum erratum_id
    err = SystemTemplateErratum.new(:erratum_id => erratum_id)
    self.errata << err
  end


  def remove_erratum erratum_id
    err = self.errata.find(:first, :conditions => {:erratum_id => erratum_id})
    err.destroy
  end


  def add_product product_name
    product = self.environment.products.find_by_name(product_name)
    if product == nil
      raise Errors::TemplateContentException.new("Product #{product_name} not found in this environment.")
    end
    self.products = (self.products << product).uniq
  end


  def remove_product product_name
    product = self.environment.products.find_by_name(product_name)
    self.products.delete(product)
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
    self.group_parameters_json = self.group_parameters.to_json
  end


  def update_revision
    self.revision = 1 if self.revision.nil?

    #increase revision number only on content attribute change
    if not self.new_record?
      content_changes = @changed_attributes.select {|k, v| (k!=:description && k!=:revision) }
      self.revision += 1 if not content_changes.empty?
    end
  end


end
