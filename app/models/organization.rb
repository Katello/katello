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


class Organization < ActiveRecord::Base

  ALLOWED_DEFAULT_INFO_TYPES = %w( system distributor )

  include Glue::Candlepin::Owner if Katello.config.use_cp
  include Glue if Katello.config.use_cp

  include Glue::Event
  def create_event
    Headpin::Actions::OrgCreate
  end
  def destroy_event
    Headpin::Actions::OrgDestroy
  end

  include AsyncOrchestration
  include Ext::PermissionTagCleanup

  include Authorization::Organization
  include Glue::ElasticSearch::Organization if Katello.config.use_elasticsearch

  include Ext::LabelFromName

  belongs_to :task_status

  has_many :activation_keys, :dependent => :destroy
  has_many :providers, :dependent => :destroy
  has_many :products, :through => :providers
  has_many :environments, :class_name => "KTEnvironment", :dependent => :destroy, :inverse_of => :organization
  has_one :library, :class_name =>"KTEnvironment", :conditions => {:library => true}, :dependent => :destroy
  has_many :gpg_keys, :dependent => :destroy, :inverse_of => :organization
  has_many :permissions, :dependent => :destroy, :inverse_of => :organization
  has_many :sync_plans, :dependent => :destroy, :inverse_of => :organization
  has_many :system_groups, :dependent => :destroy, :inverse_of => :organization
  has_many :content_view_definitions, :class_name => "ContentViewDefinitionBase", :dependent=> :destroy
  has_many :content_views, :dependent=> :destroy
  serialize :default_info, Hash

  attr_accessor :statistics

  # Organizations which are being deleted (or deletion failed) can be filtered out with this scope.
  scope :without_deleting, where(:deletion_task_id => nil)
  scope :having_name_or_label, lambda { |name_or_label| { :conditions => ["name = :id or label = :id", {:id=>name_or_label}] } }

  before_create :create_library
  before_create :create_redhat_provider
  after_initialize :initialize_default_info

  validates :name, :uniqueness => true, :presence => true
  validates_with Validators::NonHtmlNameValidator, :attributes => :name
  validates :label, :uniqueness => { :message => _("already exists (including organizations being deleted)") },
            :presence => true
  validates_with Validators::KatelloLabelFormatValidator, :attributes => :label
  validates_with Validators::KatelloDescriptionFormatValidator, :attributes => :description
  validate :unique_name_and_label
  validates_with Validators::DefaultInfoNotBlankValidator, :attributes => :default_info


  # Ensure that the name and label namespaces do not overlap
  def unique_name_and_label
    if new_record? && Organization.where("name = ? OR label = ?", label, name).any?
      errors.add(:organization, _("Names and labels must be unique across all organizations"))
    elsif label_changed? && Organization.where("id != ? AND name = ?", id, label).any?
      errors.add(:label, _("Names and labels must be unique across all organizations"))
    elsif name_changed? && Organization.where("id != ? AND label = ?", id, name).any?
      errors.add(:name, _("Names and labels must be unique across all organizations"))
    else
      true
    end
  end

  def default_content_view
    ContentView.default.where(:organization_id=>self.id).first
  end

  def systems
    System.where(:environment_id => environments)
  end

  def distributors
    Distributor.where(:environment_id => environments)
  end

  def promotion_paths
    #I'm sure there's a better way to do this
    self.environments.joins(:priors).where("prior_id = #{self.library.id}").order(:name).collect do |env|
      env.path
    end
  end

  def redhat_provider
    self.providers.redhat.first
  end

  def create_library
    self.library = KTEnvironment.new(:name => "Library", :label => "Library", :library => true, :organization => self)
  end

  def create_redhat_provider
    self.providers << ::Provider.new(:name => "Red Hat", :provider_type => ::Provider::REDHAT, :organization => self)
  end

  def validate_destroy current_org
    def_error = _("Could not delete organization '%s'.")  % [self.name]
    if (current_org == self)
      [def_error, _("The current organization cannot be deleted. Please switch to a different organization before deleting.")]
    elsif (Organization.count == 1)
      [def_error, _("At least one organization must exist.")]
    end
  end

  def being_deleted?
    ! self.deletion_task_id.nil?
  end

  def applying_default_info?
    return false if self.apply_info_task_id.nil?
    ! TaskStatus.find_by_id(self.apply_info_task_id).finished?
  end

  def initialize_default_info
    self.default_info ||= Hash.new
    ALLOWED_DEFAULT_INFO_TYPES.each do |key|
      if self.default_info[key].class != Array
        self.default_info[key] = []
      end
    end
  end

  def self.check_informable_type!(informable_type, options = {})
    defaults = {
      :message => _("Informable Type must be one of the following [ %{list} ]") %
        { :list => ALLOWED_DEFAULT_INFO_TYPES.join(", ") },
      :error => RuntimeError
    }
    options = defaults.merge(options)

    unless ALLOWED_DEFAULT_INFO_TYPES.include?(informable_type)
      raise options[:error], options[:message]
    end
  end

  def apply_default_info(informable_type, custom_info, options = {})
    options = {:async => true}.merge(options)
    Organization.check_informable_type!(informable_type)
    objects = self.send(informable_type.pluralize)
    ids_and_types = objects.inject([]) do |collection, obj|
      collection << { :informable_type => obj.class.name, :informable_id => obj.id }
    end

    if options[:async]
      task = self.async(:organization => self, :task_type => "apply default info").run_apply_info(ids_and_types, custom_info)
      self.apply_info_task_id = task.id
      self.save!
      return task
    else
      return CustomInfo.apply_to_set(ids_and_types, custom_info)
    end
  end

  def run_apply_info(ids_and_types, custom_info)
    CustomInfo.apply_to_set(ids_and_types, custom_info)
  end

end
