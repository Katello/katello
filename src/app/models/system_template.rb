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

class ParentTemplateValidator < ActiveModel::Validator
  def validate(record)
    #check if the parent is from
    if not record.parent.nil?
      record.errors[:parent] << _("Template can have parent templates only from the same environment") if record.environment_id != record.parent.environment_id
    end
  end
end

class TemplateContentValidator < ActiveModel::Validator
  def validate(record)
    #check if packages and errate are valid
    for p in record.packages
      record.errors[:packages] << _("Package '#{p.package_name}' has doesn't belong to any product in this template") if not p.valid?
    end
    for e in record.errata
      record.errors[:errata] << _("Erratum '#{e.erratum_id}' has doesn't belong to any product in this template") if not e.valid?
    end
  end
end

class SystemTemplate < ActiveRecord::Base
  #include Authorization
  include LazyAccessor

  #has_many :products
  belongs_to :environment, :class_name => "KPEnvironment", :inverse_of => :system_templates

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :environment_id
  validates_with ParentTemplateValidator
  validates_with TemplateContentValidator

  belongs_to :parent, :class_name => "SystemTemplate"
  has_and_belongs_to_many :products, :uniq => true
  has_many :errata,   :class_name => "SystemTemplateErratum", :inverse_of => :system_template, :dependent => :destroy
  has_many :packages, :class_name => "SystemTemplatePackage", :inverse_of => :system_template, :dependent => :destroy

  attr_accessor :host_group
  lazy_accessor :parameters, :initializer => lambda { init_parameters }, :unless => lambda { false }

  before_validation :attrs_to_json
  before_save :update_revision
  before_destroy :check_children


  def init_parameters
    ActiveSupport::JSON.decode((self.parameters_json or "{}"))
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

    if not json["parent"].nil?
      self.parent = SystemTemplate.find(:first, :conditions => {:name => json["parent"], :environment_id => self.environment_id})
    end

    self.revision = json["revision"]
    self.description = json["description"]
    json["products"].collect do |p| self.add_product(p) end if not json["products"].nil?
    json["packages"].collect do |p| self.add_package(p) end if not json["packages"].nil?
    json["errata"].collect   do |e| self.add_erratum(e) end if not json["errata"].nil?

    self.name = json["name"] if not json["name"].nil?

    if not json["parameters"].nil?
      json["parameters"].each_pair do |k,v|
        self.parameters[k] = v
      end
    end

  end


  def string_export
    tpl = {
      :name => self.name,
      :revision => self.revision,
      :packages => self.packages.map(&:package_name),
      :errata   => self.errata.map(&:erratum_id),
      :products => self.products.map(&:name),
      :parameters => ActiveSupport::JSON.decode(self.parameters_json)
    }
    tpl[:description] = self.description if not self.description.nil?
    tpl[:parent] = self.parent.name if not self.parent.nil?

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
    if not self.valid?
      self.products << product
      raise Errors::TemplateContentException.new("The environment still has content that belongs to product #{product_name}.")
    end
  end


  def to_json(options={})
     super(options.merge({
        :methods => [:products,
                     :packages,
                     :errata,
                     :parameters]
        })
     )
  end


  def promote
    #return if there id nowhere to promote
    return if self.environment.successor.nil?
    from_env = self.environment
    to_env   = self.environment.successor

    #collect all parent templates into one changeset
    @changeset = Changeset.create!(:environment => from_env)
    for tpl in self.get_inheritance_chain

      @changeset.products << tpl.products
      @changeset.errata   << changeset_errata(tpl.errata)
      @changeset.packages << changeset_packages(tpl.packages)
    end
    @changeset.promote

    for tpl in self.get_inheritance_chain
      #copy template to the environment
      tpl.copy_to_env to_env
    end
  end

  protected

  def changeset_errata(errata)
    errata.collect do |e|
      e = e.to_erratum
      ChangesetErratum.new(:errata_id=>e.id, :display_name=>e.title, :changeset => @changeset)
    end
  end

  def changeset_packages(packages)
    packages.collect do |p|
      p = p.to_package
      ChangesetPackage.new(:package_id=>p.id, :display_name=>p.name, :changeset => @changeset)
    end
  end

  def get_inheritance_chain
    chain = [self]
    tpl = self
    while not tpl.parent.nil?
      chain << tpl.parent
      tpl = tpl.parent
    end
    chain.reverse
  end

  def copy_to_env env
    new_tpl = SystemTemplate.new
    new_tpl.environment = env
    new_tpl.string_import(self.string_export)
    new_tpl.save!
  end

  #TODO: to be deleted after we switch to save parameters in foreman
  def attrs_to_json
    self.parameters_json = self.parameters.to_json
  end

  def update_revision
    self.revision = 1 if self.revision.nil?

    #increase revision number only on content attribute change
    if not self.new_record?
      content_changes = @changed_attributes.select {|k, v| (k!=:name && k!=:description && k!=:revision) }
      self.revision += 1 if not content_changes.empty?
    end
  end

  def check_children
    children = SystemTemplate.find(:all, :conditions => {:parent_id => self.id})
    if not children.empty?
      raise Errors::TemplateContentException.new("The template has children templates.")
    end
  end
end
