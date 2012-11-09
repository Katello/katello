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

require 'util/model_util.rb'

class ContentViewDefinition < ActiveRecord::Base
  include Katello::LabelFromName
  include Authorization::ContentViewDefinition

  has_many :content_views
  has_many :components, :class_name => "ComponentContentView"
  has_many :component_content_views, :through => :components,
    :source => :content_view, :class_name => "ContentView"
  belongs_to :organization
  has_many :filters
  has_many :content_view_definition_products
  has_many :products, :through => :content_view_definition_products
  has_many :repositories

  validates :label, :uniqueness => {:scope => :organization_id},
    :presence => true, :katello_label_format => true
  validates :name, :presence => true, :katello_name_format => true
  validates :organization, :presence => true
  validate :validate_content

  def publish
    ContentView.create!(:name => "#{name} Content View",
                        :description => "Created from #{name}",
                        :content_view_definition => self,
                        :organization => organization,
                        :environments => [organization.library]
                       )
  end

  def composite?
    self.component_content_views.any?
  end

  def has_content?
    self.products.any? || self.repositories.any? || self.filters.any?
  end

  def as_json(options = {})
    result = self.attributes
    result["organization"] = self.organization.try(:name)
    result["environments"] = self.organization.library.try(:name)
    result["published"] = false

    result
  end

  private

    def validate_content
      if has_content? && composite?
        errors.add(:base, _("cannot contain filters, products, or repositories if it contains views"))
      end
    end

end
