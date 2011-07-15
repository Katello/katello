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

class KPEnvironment < ActiveRecord::Base
  include Authorization
  set_table_name "environments"

  belongs_to :organization, :inverse_of => :environments
  has_and_belongs_to_many :priors, {:class_name => "KPEnvironment", :foreign_key => :environment_id,
    :join_table => "environment_priors", :association_foreign_key => "prior_id", :uniq => true}
  has_and_belongs_to_many :successors, {:class_name => "KPEnvironment", :foreign_key => "prior_id",
    :join_table => "environment_priors", :association_foreign_key => :environment_id, :readonly => true}
  has_and_belongs_to_many :products, { :uniq=>true }
  has_many :system_templates, :class_name => "SystemTemplate", :foreign_key => :environment_id

  has_many :systems, :inverse_of => :environment, :foreign_key => :environment_id
  has_many :working_changesets, :conditions => ["state = '#{Changeset::NEW}' OR state = '#{Changeset::REVIEW}'"], :foreign_key => :environment_id, :class_name=>"Changeset", :dependent => :destroy, :inverse_of => :environment
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
    prior_env = KPEnvironment.find env_id
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
    to_ret['prior'] = self.prior &&  self.prior.id
    to_ret
  end

  def key_for(item)
    "environment_#{id}_#{item}"
  end

  # returns list of virtual permission tags for the current user
  def self.list_tags
    select('id,name').all.collect { |m| VirtualTag.new(m.id, m.name) }
  end
end
