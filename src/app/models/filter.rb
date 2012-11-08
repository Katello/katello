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

class Filter < ActiveRecord::Base
  include Glue::ElasticSearch::Filter if AppConfig.use_elasticsearch
  include Authorization::Filter


  validates :pulp_id, :presence => true
  validates :name, :katello_name_format => true
  validates_presence_of :organization_id, :message => N_("Name cannot be blank.")
  validates :name, :katello_name_format => true, :presence => true
  validates_uniqueness_of :name, :scope => :organization_id, :message => N_("Name must be unique within one organization")
  validates_uniqueness_of :pulp_id, :message=> N_("Pulp identifier must be unique.")

  belongs_to :organization
  has_and_belongs_to_many :products, :uniq => true
  has_and_belongs_to_many :repositories, :uniq => true

  has_many :packages, :class_name=>"FilterPackage", :inverse_of=>:filter

  before_validation(:on=>:create) do
    self.pulp_id ||= "#{self.organization.label}-#{self.name}-#{SecureRandom.hex(4)}"
  end

  def add_package name
    self.packages <<  FilterPackage.new(:name=>name, :filter=>self)
  end

  def remove_package name
    self.packages.delete(self.packages.where(:name=>name).first)
    self.packages
  end

  def reconcile_packages! name_list
    pkgs = self.package_list
    (name_list - pkgs).each{|n| self.add_package(n)}
    (pkgs - name_list).each{|n| self.remove_package(n)}
  end

  def package_list
    self.packages.pluck(:name)
  end

  def as_json(options)
    to_ret = options.nil? ?
        super(:methods => [:name, :package_list], :exclude => :pulp_id) :
        super(options.merge(:methods => [:name, :package_list], :exclude => :pulp_id) {|k, v1, v2| [v1, v2].flatten })
  end

end



