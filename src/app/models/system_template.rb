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

require 'util/package_util'
require 'active_support/builder' unless defined?(Builder)
require 'mapping'

class SystemTemplate < ActiveRecord::Base
  #include Authorization
  include LazyAccessor
  include AsyncOrchestration

  belongs_to :environment, :class_name => "KTEnvironment", :inverse_of => :system_templates
  has_and_belongs_to_many :changesets

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :environment_id
  validates_length_of :name, :maximum => 255
  validates_with Validators::ParentTemplateValidator
  validates_with Validators::KatelloDescriptionFormatValidator, :attributes => :description
  validates_length_of :parameters_json, :maximum => 255

  belongs_to :parent, :class_name => "SystemTemplate"
  has_and_belongs_to_many :products, :uniq => true
  has_many :packages, :class_name => "SystemTemplatePackage", :inverse_of => :system_template, :dependent => :destroy
  has_many :package_groups, :class_name => "SystemTemplatePackGroup", :inverse_of => :system_template, :dependent => :destroy
  has_many :pg_categories, :class_name => "SystemTemplatePgCategory", :inverse_of => :system_template, :dependent => :destroy
  has_many :distributions, :class_name => "SystemTemplateDistribution", :inverse_of => :system_template, :dependent => :destroy

  has_many :system_template_repositories, :dependent => :destroy
  has_many :repositories, :through => :system_template_repositories

  attr_accessor :host_group
  lazy_accessor :parameters, :initializer => lambda {|s| init_parameters }, :unless => lambda {|s| false }

  before_validation :attrs_to_json
  after_initialize :save_content_state
  before_save :update_revision
  before_destroy :check_children
  after_save :update_related_index

  def init_parameters
    ActiveSupport::JSON.decode((self.parameters_json or "{}"))
  end


  def import tpl_file_path
    Rails.logger.debug "Importing into template #{name}"

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
    self.name = json["name"] if json["name"]
    self.save!
    #bz 799149
    #json["products"].each {|p| self.add_product(p) } if json["products"]
    json["packages"].each {|p| self.add_package(p) } if json["packages"]
    json["package_groups"].each {|pg| self.add_package_group(pg) } if json["package_groups"]
    json["package_group_categories"].each {|pgc| self.add_pg_category(pgc) } if json["package_group_categories"]
    json["distributions"].each {|d| self.add_distribution(d) } if json["distributions"]
    json["parameters"].each_pair {|k,v| self.parameters[k] = v } if json["parameters"]
    json["repositories"].each {|r| self.add_repo_by_name(r["product"], r["name"]) } if json["repositories"]

    self.save_content_state
  end

  def export_as_hash
    tpl = {
      :name => self.name,
      :revision => self.revision,
      :packages => self.packages.map(&:nvrea),
      #bz 799149
      #:products => self.products.map(&:name),
      :parameters => ActiveSupport::JSON.decode(self.parameters_json || "{}"),
      :package_groups => self.package_groups.map(&:name),
      :package_group_categories => self.pg_categories.map(&:name),
      :distributions => self.distributions.map(&:distribution_pulp_id),
      :repositories => self.repositories.collect{ |r| {:product => r.product.name, :name => r.name} }
    }
    tpl[:description] = self.description if not self.description.nil?
    tpl
  end

  def export_as_json
    self.export_as_hash.to_json
  end

  # Validates if this template can be exported in TDL:
  # - at least one product is present (1)
  # - exactly one distribution is present (2)
  # - ueber certificate for it's organization has been generated (3)
  #
  # Throws exception when template does not pass all validations.
  def validate_tdl
    verrors = []

    # (1)
    verrors << _("At least repository must be present to export a TDL") if (self.products.count < 1 and self.repositories.count < 1)

    # (2)
    verrors << _("Exactly one distribution must be present to export a TDL") if self.distributions.count != 1

    raise Errors::TemplateValidationException.new(_("Template cannot be exported"), verrors) if verrors.count > 0
    true
  end

  # Returns template in XML TDL format:
  # https://github.com/aeolusproject/imagefactory/blob/master/Documentation/TDL.xsd
  #
  # Method validate_tdl MUST be called before exporting, this method expects
  # validated system template.
  def export_as_tdl
    xm = Builder::XmlMarkup.new
    xm.instruct!

    validate_tdl

    begin
      uebercert = self.environment.organization.debug_cert
    rescue RestClient::ResourceNotFound => e
      uebercert = nil
    end

    # determine the list of repos to include in the export based on the products & repos in the template...
    # this is to avoid duplicate repos from being included.
    repos = {}
    self.products.each do |product|
      product.repos(self.environment).each do |repo|
        repos[repo.id] = repo
      end
    end
    self.repositories.each do |repo|
      repos[repo.id] = repo
    end

    xm.template {
      # mandatory tags
      xm.name self.name
      if self.distributions.count == 1
        xm.os {
          distro = self.distributions.first
          family, version = Mapping::ImageFactoryNaming.translate(distro.family, distro.version)
          xm.name family
          xm.version version
          xm.arch distro.arch
          xm.install("type" => "url") {
            xm.url distro.url_for_environment(self.environment)
          }
          # TODO root password is hardcoded for now
          xm.rootpw "redhat"
        }
      end
      # optional tags
      xm.description self.description unless self.description.nil?
      xm.packages {
        self.packages.each { |p| xm.package "name" => p.package_name }
        self.package_groups.each { |p| xm.package "name" => "@#{p.name}" }
        # TODO package groups categories ("unwrap" them here - we need to create category->repository reference in our model)
      }
      xm.repositories {
        repos.each do |repoId, repo|
          xm.repository("name" => repo.name) {
            xm.url repo.uri
            xm.persisted "No"
            xm.clientcert uebercert[:cert] unless uebercert.nil?
            xm.clientkey uebercert[:key] unless uebercert.nil?
          }
        end
      }
    }
  end


  def add_package package_name
    self.packages.create!(:package_name => package_name)
  end


  def remove_package package_name
    package = self.packages.find(:first, :conditions => {:package_name => package_name})

    self.packages.delete(package)
  end

  def add_product product_name
    product = self.environment.products.find_by_name(product_name)
    if product == nil
      raise Errors::TemplateContentException.new(_("Product '%s' not found in this environment.") % product_name)
    elsif self.products.include? product
      raise Errors::TemplateContentException.new(_("Product '%s' is already present in the template.") % product_name)
    end
    self.products << product
  end

  def remove_product product_name
    product = self.environment.products.find_by_name(product_name)
    self.products.delete(product)
  rescue ActiveRecord::RecordInvalid
    raise Errors::TemplateContentException.new(_("The environment still has content that belongs to product '%s'.") % product_name)
  end

  def add_product_by_cpid cp_id
    product = self.environment.products.find_by_cp_id(cp_id)
    if product == nil
      raise Errors::TemplateContentException.new(_("Product '%s' not found in this environment.") % cp_id)
    elsif self.products.include? product
      raise Errors::TemplateContentException.new(_("Product '%s' is already present in the template.") % cp_id)
    end
    self.products << product
  end

  def remove_product_by_cpid cp_id
    product = self.environment.products.find_by_cp_id(cp_id)
    self.products.delete(product)
  rescue ActiveRecord::RecordInvalid
    raise Errors::TemplateContentException.new(_("The environment still has content that belongs to product '%s'.") % cp_id)
  end

  def set_parameter key, value
    self.parameters[key] = value
  end

  def remove_parameter key
    if not self.parameters.has_key? key
      raise Errors::TemplateContentException.new(_("Parameter '%s' not found in the template.") % key)
    end
    self.parameters.delete(key)
  end

  def add_package_group pg_name
    self.package_groups.create!(:name => pg_name)
  end

  def remove_package_group pg_name
    package_group = self.package_groups.where(:name => pg_name).first
    if package_group == nil
      raise Errors::TemplateContentException.new(_("Package group '%s' not found in this template.") % pg_name)
    end
    self.package_groups.delete(package_group)
  end

  def add_pg_category pg_cat_name
    self.pg_categories.create!(:name => pg_cat_name)
  end

  def remove_pg_category pg_cat_name
    pg_category = self.pg_categories.where(:name => pg_cat_name).first
    if pg_category == nil
      raise Errors::TemplateContentException.new(_("Package group category '%s' not found in this template.") % pg_cat_name)
    end
    self.pg_categories.delete(pg_category)
  end

  def add_distribution pulp_id
    self.distributions.create!(:distribution_pulp_id => pulp_id)
  end

  def remove_distribution pulp_id
    distro = self.distributions.where(:distribution_pulp_id => pulp_id).first
    raise Errors::TemplateContentException.new(_("Distribution '%s' not found in this template.") % pulp_id) if distro.nil?
    self.distributions.delete(distro)
  end

  def add_repo id
    repo = Repository.find(id)

    raise Errors::TemplateContentException.new(_("Repository '%s' not found in this environment.") % id) if (repo == nil) || (repo.environment != self.environment)
    raise Errors::TemplateContentException.new(_("Repository '%s' is already present in the template.") % id) if self.repositories.include? repo
    self.repositories << repo
  end

  def add_repo_by_name product_name, repo_name
    product = Product.joins(:environment_products).where(:name => product_name, 'environment_products.environment_id' => self.environment_id).first
    raise Errors::TemplateContentException.new(_("Product '%s' not found in this environment.") % product_name) if product == nil

    repo = Repository.joins(:environment_product).where(:name => repo_name, 'environment_products.environment_id' => self.environment_id, 'environment_products.product_id' => product.id).first

    raise Errors::TemplateContentException.new(_("Repository '%s' not found in this environment.") % repo_name) if repo == nil
    raise Errors::TemplateContentException.new(_("Repository '%s' is already present in the template.") % repo_name) if self.repositories.include? repo
    self.repositories << repo
  end

  def remove_repo id
    repo = self.repositories.where(:id => id).first
    raise Errors::TemplateContentException.new(_("Repository '%s' not found in this template.") % id) if repo.nil?
    self.repositories.delete(repo)
  end

  def to_json(options={})
     super(options.merge({
        :methods => [:products,
                     :packages,
                     :parameters,
                     :package_groups,
                     :pg_categories,
                     :repositories]
        })
     )
  end

  def get_promotable_packages from_env, to_env, tpl_pack
    if tpl_pack.is_nvr?
      #if specified by nvre, ensure the nvre is there, othervise promote it
      return [] if to_env.find_packages_by_nvre(tpl_pack.package_name, tpl_pack.version, tpl_pack.release, tpl_pack.epoch).length > 0
      from_env.find_packages_by_nvre(tpl_pack.package_name, tpl_pack.version, tpl_pack.release, tpl_pack.epoch)

    else
      #if specified by name, ensure any package with this name is in the next env. If not, promote the latest.
      return [] if to_env.find_packages_by_name(tpl_pack.package_name).length > 0
      from_env.find_latest_packages_by_name(tpl_pack.package_name)
    end
  end


  def promote from_env, to_env
    # TODO: add logic to promote parent templates
    # when that feature arrives
    promote_products from_env, to_env
    promote_repos    from_env, to_env
    promote_packages from_env, to_env
    promote_template from_env, to_env

    []
  end


def remove from_env
    remove_template from_env
    # TODO: add logic to deal with removal of parent templates
    # when that feature arrives
    []
end



  def get_clones
    Organization.find(self.environment.organization_id).environments.collect do |env|
      env.system_templates.where(:name => self.name_was)
    end.flatten(1)
  end


  #### Permissions
  def self.list_verbs global = false
    {
      :manage_all => _("Administer System Templates"),
      :read_all => _("Read System Templates")
   }.with_indifferent_access
  end

  def self.read_verbs
    [:read_all]
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

  def repos_to_be_promoted
    repos = self.repositories || []
    if self.parent
      parent_repos = self.parent.repos_to_be_promoted
      repos += parent_repos if parent_repos
    end
    return repos.uniq
  end

  def products_to_be_promoted
    products = self.products || []
    if self.parent
      parent_products = self.products_to_be_promoted
      products += parent_products if parent_product
    end
    return products.uniq
  end

  protected

  def update_related_index
    if self.name_changed?
      keys = ActivationKey.where(:system_template_id=>self.id)
      ActivationKey.index_import(keys) if !keys.empty?
      changesets =  Changeset.joins(:system_templates).where("system_templates.id"=>self.id)
      Changeset.index_import(changesets) if !changesets.empty?
    end
  end

  def remove_template from_env
    tpl_copy = from_env.system_templates.find_by_name(self.name)
    tpl_copy.delete if tpl_copy
  end

  def promote_template from_env, to_env
    #clone the template
    tpl_copy = to_env.system_templates.find_by_name(self.name)
    tpl_copy.delete if not tpl_copy.nil?

    new_tpl_copy = self.copy_to_env to_env
    new_tpl_copy.parent = to_env.system_templates.find_by_name(self.parent.name) if self.parent
    new_tpl_copy.save!
  end

  def promote_products from_env, to_env
    #promote the product only if it is not in the next env yet
    async_tasks = []
    self.products.each do |prod|
      async_tasks += (prod.promote from_env, to_env) if not prod.environments.include? to_env
    end
    PulpTaskStatus::wait_for_tasks async_tasks
  end

  def promote_repos from_env, to_env
    async_tasks = []
    self.repositories.each do |repo|
      product = repo.product
      next if (products.uniq! or []).include? product

      cloned = repo.get_clone(to_env)
      if cloned
        async_tasks += cloned.sync
      else
        async_tasks += repo.promote(from_env, to_env)
      end
    end
    PulpTaskStatus::wait_for_tasks async_tasks
    async_tasks
  end

  def promote_packages from_env, to_env
    pkgs_promote = {}
    self.packages.each do |tpl_pack|

      #get packages that need to be promoted
      #in case there are more suitable packages (eg. two latest packages in two different repos in one product) we try to promote them all
      packages = self.get_promotable_packages from_env, to_env, tpl_pack
      next if packages.empty?

      any_package_promoted = false
      packages.each do |p|
        p = p.with_indifferent_access

        #check if there's where to promote them
        repo = Repository.find(p[:repo_id])
        if repo.is_cloned_in? to_env
          #remember the packages in a hash, we add them all one time
          clone = repo.get_clone to_env
          pkgs_promote[clone] ||= []
          pkgs_promote[clone] << p[:id]
          any_package_promoted = true
        end
      end

      if not any_package_promoted
        #there wasn't any package that we could promote (either it's product or repo have not been promoted yet)
        packages.map{|p| p[:product_id]}.uniq.each do |product_id|
          #promote (or sync) the product
          prod = Product.find_by_cp_id product_id
          PulpTaskStatus::wait_for_tasks prod.promote(from_env, to_env)
        end
      end
    end

    #promote all collected packages
    pkgs_promote.each_pair do |repo, pkgs|
      repo.add_packages(pkgs)
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
    new_tpl.string_import(self.export_as_json)
    new_tpl.save!
    new_tpl
  end

  #TODO: to be deleted after we switch to save parameters in foreman
  def attrs_to_json
    self.parameters_json = self.parameters.to_json
  end

  def get_content_state
    content = self.export_as_hash
    content.delete(:name)
    content.delete(:description)
    content.delete(:revision)
    content
  end

  def save_content_state
    @old_content = self.get_content_state
  end

  def content_changed?
    old_content_json     = @old_content.to_json
    current_content_json = self.get_content_state.to_json
    not (old_content_json.eql? current_content_json)
  end

  def update_revision
    self.revision = 1 if self.revision.nil?

    #increase revision number only on content attribute change
    if not self.new_record? and self.content_changed?
      self.revision += 1
      self.save_content_state
    end
  end

  def check_children
    children = SystemTemplate.find(:all, :conditions => {:parent_id => self.id})
    if not children.empty?
      raise Errors::TemplateContentException.new(_("The template has children templates."))
    end
  end

end
