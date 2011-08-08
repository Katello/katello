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

class Provider < ActiveRecord::Base
  include Glue::Provider
  include Glue
  include Authorization
  include KatelloUrlHelper

  REDHAT = 'Red Hat'
  CUSTOM = 'Custom'
  TYPES = [REDHAT, CUSTOM]
  belongs_to :organization
  has_many :products, :inverse_of => :provider

  validates :name, :presence => true, :katello_name_format => true
  validates :description, :katello_description_format => true
  validates_uniqueness_of :name, :scope => :organization_id
  validates_inclusion_of :provider_type,
    :in => TYPES,
    :allow_blank => false,
    :message => "Please select provider type from one of the following: #{TYPES.join(', ')}."
  before_validation :sanitize_repository_url

  scoped_search :on => :name, :complete_value => true, :rename => :'provider.name'
  scoped_search :on => :description, :complete_value => true, :rename => :'provider.description'
  scoped_search :on => :repository_url, :complete_value => true, :rename => :'provider.url'
  scoped_search :on => :provider_type, :complete_value => true, :rename => :'provider.type'
  scoped_search :in => :products, :on => :name, :complete_value => true, :rename => :'custom_product.name'
  scoped_search :in => :products, :on => :description, :complete_value => true, :rename => :'custom_product.description'

  validate :only_one_rhn_provider
  validate :valid_url, :if => :rh_repo?

  def only_one_rhn_provider
    # validate only when new record is added (skip explicit valid? calls)
    if new_record? and provider_type == REDHAT and count_providers(REDHAT) != 0
      errors.add(:base, _("Only one Red Hat provider permitted for an Organization"))
    end
  end

  def valid_url
    errors.add(:repository_url, _("is invalid")) unless kurl_valid?(self.repository_url)
  end

  def count_providers type
    ::Provider.where(:organization_id => self.organization_id, :provider_type => type).count(:id)
  end

  def yum_repo?
    provider_type == CUSTOM
  end

  def rh_repo?
    provider_type == REDHAT
  end

  # Logic to ask a Provider if it is one that has subscriptions managed for
  # the products contained within.  Right now this is just redhat products but
  # wanted to centralize the logic in one method.
  def has_subscriptions?
    rh_repo?
  end

  # returns list of virtual permission tags for the current user
  def self.list_tags
    select('id,name').all.collect { |m| VirtualTag.new(m.id, m.name) }
  end

  protected

   def sanitize_repository_url
     if self.repository_url
       self.repository_url.strip!
     end
   end

end

