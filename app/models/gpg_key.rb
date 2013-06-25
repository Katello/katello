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


class GpgKey < ActiveRecord::Base

  include Glue::ElasticSearch::GpgKey if Katello.config.use_elasticsearch
  include Authorization::GpgKey
  MAX_CONTENT_LENGTH = 100000

  has_many :repositories, :inverse_of => :gpg_key
  has_many :products, :inverse_of => :gpg_key

  belongs_to :organization, :inverse_of => :gpg_keys

  validates :name, :presence => true
  validates_with Validators::KatelloNameFormatValidator, :attributes => :name
  validates :content, :presence => true
  validates_with Validators::ContentValidator, :attributes => :content
  validates_length_of :content, :maximum => MAX_CONTENT_LENGTH
  validates_presence_of :organization
  validates_uniqueness_of :name, :scope => :organization_id, :message => N_("Label has already been taken")

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
