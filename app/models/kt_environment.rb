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

class SelfReferenceEnvironmentValidator < ActiveModel::Validator
  def validate(record)
    record.errors[:base] << _("Environment cannot be in its own promotion path") if record.priors.select(:id).include? record.id
  end
end

class PriorValidator < ActiveModel::Validator
  def validate(record)
    #need to ensure that prior
    #environment already does not have a successor
    #this is because in v1.0 we want
    # prior to have only one child (unless its the Locker)
    has_no_prior = record.organization.environments.reject{|env| env == record || env.prior != record.prior || env.prior == env.organization.locker}.empty?
    record.errors[:prior] << _("environment cannot be a prior to a different environment") unless has_no_prior

    # only Locker can have prior=nil
    record.errors[:prior] << _("environment required") unless !record.prior.nil? || record.locker?
  end
end


class PathDescendentsValidator < ActiveModel::Validator
  def validate(record)
    #need to ensure that
    #environment is not duplicated in its path
    # We do not want circular dependencies
    return if record.prior.nil?
     record.errors[:prior] << _(" environment cannot be set to an environment already on its path") if is_duplicate? record.prior
  end

  def is_duplicate? record
    s = record.successor
    ret = [record.id]
    until s.nil?
      return true if ret.include? s.id
      ret << s.id
      s = s.successor
    end
    false
  end
end

class KTEnvironment < ActiveRecord::Base
  include Authorization
  set_table_name "environments"

  belongs_to :organization, :inverse_of => :environments
  has_many :activation_keys, :dependent => :destroy, :foreign_key => :environment_id
  has_and_belongs_to_many :priors, {:class_name => "KTEnvironment", :foreign_key => :environment_id,
    :join_table => "environment_priors", :association_foreign_key => "prior_id", :uniq => true}
  has_and_belongs_to_many :successors, {:class_name => "KTEnvironment", :foreign_key => "prior_id",
    :join_table => "environment_priors", :association_foreign_key => :environment_id, :readonly => true}
  has_and_belongs_to_many :products, { :uniq=>true }
  has_many :system_templates, :class_name => "SystemTemplate", :foreign_key => :environment_id

  has_many :systems, :inverse_of => :environment, :foreign_key => :environment_id
  has_many :working_changesets, :conditions => ["state != '#{Changeset::PROMOTED}'"], :foreign_key => :environment_id, :class_name=>"Changeset", :dependent => :destroy, :inverse_of => :environment
  has_many :changeset_history, :conditions => {:state => Changeset::PROMOTED}, :foreign_key => :environment_id, :class_name=>"Changeset", :dependent => :destroy, :inverse_of => :environment

  validates_uniqueness_of :name, :scope => :organization_id, :message => N_("must be unique within one organization")

  validates :name, :presence => true, :katello_name_format => true
  validates :description, :katello_description_format => true
  validates_with PriorValidator
  validates_with PathDescendentsValidator

  def locker?
    self.locker
  end

  def successor
    return self.successors[0] unless self.locker?
    self.organization.promotion_paths()[0][0] if !self.organization.promotion_paths().empty?
  end

  def prior
    self.priors[0]
  end

  def prior=(env_id)
    self.priors.clear
    return if env_id.nil? || env_id == ""
    prior_env = KTEnvironment.find env_id
    self.priors << prior_env unless prior_env.nil?
  end

  def path
    s = self.successor
    ret = [self]
    until s.nil?
      raise "Environment path has duplicates!!. #{self}. Duplicate => #{ret}. Path => #{s}" if ret.include? s
      ret << s
      s = s.successor
    end
    ret
  end

  #is the environment currently being promoted to
  def promoting_to?
    Changeset.joins(:task_status).where('changesets.environment_id' => self.id,
        'task_statuses.state' => [TaskStatus::Status::WAITING,  TaskStatus::Status::RUNNING]).exists?
  end


  #Unlike path which only gives the path from this environment going forward
  #  Get the full path, that is go to the HEAD of the path this environment is on
  #  and then give me that entire path
  def full_path
    p = self
    until p.prior.nil? or p.prior.locker
      p = p.prior
    end
    p.prior.nil? ? p.path : [p.prior] + p.path
  end

  def available_products
    if self.prior.locker
      # if there is no prior, then the prior is the Locker, which has all products
      prior_products = self.organization.locker.products
    else
      prior_products = self.prior.products
    end
    return prior_products - self.products
  end


  def as_json options = {}
    to_ret = self.attributes
    to_ret['prior'] = self.prior &&  self.prior.name
    to_ret['organization'] = self.organization &&  self.organization.name
    to_ret
  end

  def key_for(item)
    "environment_#{id}_#{item}"
  end

  # returns list of virtual permission tags for the current user
  def self.list_tags org_id
    select('id,name').where(:organization_id=>org_id).collect { |m| VirtualTag.new(m.id, m.name) }
  end

  def self.tags(ids)
    select('id,name').where(:id => ids).collect { |m| VirtualTag.new(m.id, m.name) }
  end


  #Permissions
  scope :changesets_readable, lambda {|org| authorized_items(org, [:promote_changesets, :manage_changesets, :read_changesets])}
  scope :content_readable, lambda {|org| authorized_items(org, [:read_contents])}
  scope :systems_readable, lambda{|org|
    if  org.systems_readable?
      where(:organization_id => org)
    else
      authorized_items(org, SYSTEMS_READABLE)
    end
  }

  def self.any_viewable_for_promotions? org
    User.allowed_to?(CHANGE_SETS_READABLE + CONTENTS_READABLE, :environments, [], org)
  end

  def viewable_for_promotions?
    User.allowed_to?(CHANGE_SETS_READABLE + CONTENTS_READABLE, :environments, self.id, self.organization)
  end


  def changesets_promotable?
    User.allowed_to?([:promote_changesets], :environments, self.id,
                              self.organization)
  end

  CHANGE_SETS_READABLE = [:manage_changesets, :read_changesets, :promote_changesets]
  def changesets_readable?
    User.allowed_to?(CHANGE_SETS_READABLE, :environments,
                              self.id, self.organization)
  end

  def changesets_manageable?
    User.allowed_to?([:manage_changesets], :environments, self.id,
                              self.organization)
  end

  CONTENTS_READABLE = [:read_contents]
  def contents_readable?
    User.allowed_to?([:read_contents], :environments, self.id,
                              self.organization)
  end


  SYSTEMS_READABLE = [:read_systems, :create_systems, :update_systems, :delete_systems]
  def systems_readable?
    self.organization.systems_readable? ||
        User.allowed_to?(SYSTEMS_READABLE, :environments, self.id, self.organization)
  end

  def systems_editable?
    User.allowed_to?([:create_systems, :update_systems], :organizations, nil, self.organization) ||
        User.allowed_to?([:create_systems, :update_systems], :environments, self.id, self.organization)
  end

  def systems_deletable?
    User.allowed_to?([:create_systems, :delete_systems], :organizations, nil, self.organization) ||
        User.allowed_to?([:create_systems, :delete_systems], :environments, self.id, self.organization)
  end


  def self.authorized_items org, verbs, resource = :environments
    raise "scope requires an organization" if org.nil?
    if User.allowed_all_tags?(verbs, resource, org)
       where(:organization_id => org)
    else
      where("environments.id in (#{User.allowed_tags_sql(verbs, resource, org)})")
    end
  end

  def self.list_verbs global = false
    {
      :read_contents => N_("Access Environment Contents"),
      :read_systems => N_("Access Systems in Environment"),
      :create_systems =>N_("Register Systems in Environment"),
      :update_systems => N_("Manage Systems in Environment"),
      :delete_systems => N_("Remove Systems in Environment"),
      :read_changesets => N_("Access Changesets in Environment"),
      :manage_changesets => N_("Manage Changesets in Environment"),
      :promote_changesets => N_("Promote Changesets in Environment")
    }.with_indifferent_access
  end

end
