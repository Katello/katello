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
      record.errors[:packages] << _("Package '#{p.package_name}' does not belong to any product in this template") if not p.valid?
    end
  end
end

class SystemTemplate < ActiveRecord::Base
  #include Authorization
  include LazyAccessor
  include AsyncOrchestration

  #has_many :products
  belongs_to :environment, :class_name => "KTEnvironment", :inverse_of => :system_templates
  has_and_belongs_to_many :changesets

  scoped_search :on => :name, :complete_value => true, :rename => :'system_template.name'

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :environment_id
  validates_with ParentTemplateValidator
  validates_with TemplateContentValidator

  belongs_to :parent, :class_name => "SystemTemplate"
  has_and_belongs_to_many :products, :uniq => true
  has_many :packages, :class_name => "SystemTemplatePackage", :inverse_of => :system_template, :dependent => :destroy
  has_many :package_groups, :class_name => "SystemTemplatePackGroup", :inverse_of => :system_template, :dependent => :destroy
  has_many :pg_categories, :class_name => "SystemTemplatePgCategory", :inverse_of => :system_template, :dependent => :destroy

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
    json["products"].each {|p| self.add_product(p) } if json["products"]
    json["packages"].each {|p| self.add_package(p) } if json["packages"]
    json["package_groups"].each {|pg| self.add_package_group(pg.symbolize_keys) } if json["package_groups"]
    json["package_group_categories"].each {|pgc| self.add_pg_category(pgc.symbolize_keys) } if json["package_group_categories"]

    self.name = json["name"] if json["name"]

    json["parameters"].each_pair {|k,v| self.parameters[k] = v } if json["parameters"]
  end


  def string_export
    tpl = {
      :name => self.name,
      :revision => self.revision,
      :packages => self.packages.map(&:package_name),
      :products => self.products.map(&:name),
      :parameters => ActiveSupport::JSON.decode(self.parameters_json),
      :package_groups => self.package_groups.map(&:export_hash),
      :package_group_categories => self.pg_categories.map(&:export_hash)
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
    save!
  rescue ActiveRecord::RecordInvalid
    raise Errors::TemplateContentException.new("The environment still has content that belongs to product #{product_name}.")
  end

  def add_package_group pg_attrs
      self.package_groups.create!(:repo_id => pg_attrs[:repo_id], :package_group_id => pg_attrs[:id])
  end

  def remove_package_group pg_attrs
    package_group = self.package_groups.where(:repo_id => pg_attrs[:repo_id], :package_group_id => pg_attrs[:id]).first
    if package_group == nil
      raise Errors::TemplateContentException.new(_("Package group '%s' not found in this template.") % pg_attrs[:repo_id])
    end
    package_group.delete
  end

  def add_pg_category pg_cat_attrs
    self.pg_categories.create!(:repo_id => pg_cat_attrs[:repo_id], :pg_category_id => pg_cat_attrs[:id])
  end

  def remove_pg_category pg_cat_attrs
    pg_category = self.pg_categories.where(:repo_id => pg_cat_attrs[:repo_id], :pg_category_id => pg_cat_attrs[:id]).first
    if pg_category == nil
      raise Errors::TemplateContentException.new(_("Package group category '%s' not found in this template.") % pg_cat_attrs[:id])
    end
    pg_category.delete
  end

  def to_json(options={})
     super(options.merge({
        :methods => [:products,
                     :packages,
                     :parameters,
                     :package_groups,
                     :pg_categories
     ]
        })
     )
  end

  def promote from_env, to_env
    #TODO: promote parent templates recursively

    #promote all products
      #promote the product only if it is not in the next env yet
    async_tasks = []
    self.products.each do |prod|
      async_tasks << (prod.promote from_env, to_env) if not prod.environments.include? to_env
    end.flatten(1)
    PulpTaskStatus::wait_for_tasks async_tasks

    #TODO: promote packages
      #if specified by nvre, ensure the nvre is there, othervise promote it
      #if specified by name, ensure any package with this name is in the next env. If not, promote the latest.


    #clone the template
      #try to find template in the next env. If it is there, delete it
      #clone the template to the next environment
    tpl_copy = to_env.system_templates.find_by_name(self.name)
    if not tpl_copy.nil?
      tpl_copy.delete
    end
    self.copy_to_env to_env

    async_tasks
  end

  #### Permissions
  def self.list_verbs global = false
    {
      :manage_all => N_("Manage All System Templates"),
      :read_all => N_("Read All System Templates")
   }.with_indifferent_access
  end

  def self.no_tag_verbs
    SystemTemplate.list_verbs.keys
  end

  def self.any_readable? org
    User.allowed_to?([:read_all, :manage_all], :system_templates, nil, org)

  end

  def self.readable? org
    User.allowed_to?([:read_all, :manage_all], :system_templates, nil, org)
  end

  def self.manageable? org
    User.allowed_to?([:manage_all], :system_templates, nil, org)
  end

  def readable?
    self.class.readable?(self.environment.organization)
  end


  protected

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
