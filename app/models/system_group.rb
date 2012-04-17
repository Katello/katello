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

class SystemGroup < ActiveRecord::Base


  include Glue::Pulp::ConsumerGroup if (AppConfig.use_pulp)
  include Glue
  include Authorization
  include IndexedModel

  index_options :extended_json=>:extended_index_attrs,
                :display_attrs=>[:name, :description],
                :json=>{}

  mapping do
    indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
    indexes :description, :type => 'string', :analyzer => :kt_name_analyzer
    indexes :name_sort, :type => 'string', :index => :not_analyzed
  end

  has_many :key_system_groups, :dependent => :destroy
  has_many :activation_keys, :through => :key_system_groups

  validates :pulp_id, :presence => true
  validates :name, :presence => true, :katello_name_format => true
  validates_presence_of :organization_id, :message => N_("Organization cannot be blank.")
  validates_uniqueness_of :name, :scope => :organization_id, :message => N_("Name must be unique within one organization")
  validates_uniqueness_of :pulp_id, :message=> N_("Pulp identifier must be unique.")


  belongs_to :organization

  before_validation(:on=>:create) do
    self.pulp_id ||= "#{self.organization.cp_key}-#{self.name}-#{SecureRandom.hex(4)}"
  end

  scope :readable, lambda { |org|
        where(:organization_id => org.id)
  }

  def self.creatable? org
    true
  end

  def readable?
    true
  end

  def editable?
    true
  end


  def deletable?
    true
  end


  def extended_index_attrs
    {}
  end

end
