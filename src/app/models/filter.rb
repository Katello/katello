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
  include Glue::Pulp::Filter if Katello.config.katello?
  include Glue
  include Authorization
  include IndexedModel

  index_options :extended_json=>:extended_index_attrs,
                :display_attrs=>[:name, :packages, :products],
                :json=>{:except=>[:pulp_id, :package_list]}

  mapping do
    indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
    indexes :name_sort, :type => 'string', :index => :not_analyzed
  end

  validates :pulp_id, :presence => true
  validates_presence_of :organization_id, :message => N_("Name cannot be blank.")
  validates :name, :presence => true
  validates_with Validators::KatelloNameFormatValidator, :attributes => :name
  validates_uniqueness_of :name, :scope => :organization_id, :message => N_("Name must be unique within one organization")
  validates_uniqueness_of :pulp_id, :message=> N_("Pulp identifier must be unique.")

  belongs_to :organization
  has_and_belongs_to_many :products, :uniq => true
  has_and_belongs_to_many :repositories, :uniq => true

  before_validation(:on=>:create) do
    self.pulp_id ||= "#{self.organization.label}-#{self.name}-#{SecureRandom.hex(4)}"
  end


  READ_PERM_VERBS = [:read, :create, :delete]
  UPDATE_PERM_VERBS = [:create, :update]

  def readable?
    User.allowed_to?(READ_PERM_VERBS, :filters, self.id, self.organization)
  end

  def editable?
    User.allowed_to?(UPDATE_PERM_VERBS, :filters, self.id, self.organization)
  end

  def deletable?
     User.allowed_to?([:delete, :create], :filters, self.id, self.organization)
  end

  def self.list_tags org_id
    select('id,pulp_id').where(:organization_id=>org_id).collect { |m| VirtualTag.new(m.id, m.pulp_id) }
  end

  def self.tags(ids)
    select('id,pulp_id').where(:id => ids).collect { |m| VirtualTag.new(m.id, m.pulp_id) }
  end

  def self.list_verbs  global = false
    {
       :create => _("Administer Package Filters"),
       :read => _("Read Package Filters"),
       :delete => _("Delete Package Filters"),
       :update => _("Modify Package Filters")
    }.with_indifferent_access
  end

  def self.read_verbs
    [:read]
  end

  def self.no_tag_verbs
    Filter.list_verbs.keys
  end


  def self.creatable? org
    User.allowed_to?([:create], :filters, nil, org)
  end

  def self.any_editable? org
    User.allowed_to?(UPDATE_PERM_VERBS, :filters, nil, org)
  end

  def self.any_readable?(org)
    User.allowed_to?(READ_PERM_VERBS, :filters, nil, org)
  end

  def self.readable_items org
    raise "scope requires an organization" if org.nil?
    resource = :filters
    verbs = READ_PERM_VERBS
    if User.allowed_all_tags?(verbs, resource, org)
       where(:organization_id => org)
    else
      where("filters.id in (#{User.allowed_tags_sql(verbs, resource, org)})")
    end
  end


  def as_json(options)
    options.nil? ?
        super(:methods => [:name], :exclude => :pulp_id) :
        super(options.merge(:methods => [:name], :exclude => :pulp_id) {|k, v1, v2| [v1, v2].flatten })
  end

  def extended_index_attrs
    {:name_sort=>name.downcase, :name=>name, :packages=>self.package_list, :products=>self.products.collect{|p| p.name}}
  end


end



