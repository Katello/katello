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


class ContentValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    begin
      Iconv.conv("UTF8", "UTF8", value)
    rescue
      record.errors[attribute] << (options[:message] || _("cannot be a binary file."))
    end
  end
end

class GpgKey < ActiveRecord::Base
  include IndexedModel


  index_options :extended_json=>:extended_index_attrs,
                :display_attrs=>[:name, :content]

  mapping do
    indexes :name, :type => 'string', :analyzer => :kt_name_analyzer
    indexes :name_sort, :type => 'string', :index => :not_analyzed
  end


  has_many :repositories, :inverse_of => :gpg_key
  has_many :products, :inverse_of => :gpg_key

  belongs_to :organization, :inverse_of => :gpg_keys

  validates :name, :katello_name_format => true
  validates :content, :presence => true, :content => true
  validates_presence_of :organization
  validates_uniqueness_of :name, :scope => :organization_id, :message => N_("must be unique within one organization")


  #Permission items
  scope :readable, lambda { |org|
     if org.readable? || org.gpg_keys_manageable? || ::Provider.any_readable?(org)
        where(:organization_id => org.id)
     else
       where("0 = 1")
     end
  }

  scope :manageable, lambda { |org|
     if org.gpg_keys_manageable?
        where(:organization_id => org.id)
     else
       where("0 = 1")
     end
  }

  def  readable?
    GpgKey.any_readable?(organization)
  end

  def manageable?
    organization.gpg_keys_manageable?
  end

  def self.createable? organization
    organization.gpg_keys_manageable?
  end
  
  def self.any_readable? organization
    organization.readable? || organization.gpg_keys_manageable? || ::Provider.any_readable?(organization)
  end

  def extended_index_attrs
    {:name_sort=>name.downcase}
  end

  def as_json(options = {})
    options ||= {}
    ret = super(options.except(:details))
    if options[:details]
      ret[:products] = products.map {|p| {:name => p.name}}
      ret[:repositories] = repositories.map {|r| {:product => {:name => r.product.name}, :name => r.name}}
    end
    ret
  end
end
