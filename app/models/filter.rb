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

class Filter < ActiveRecord::Base
  belongs_to :content_view_definition, :class_name => "ContentViewDefinitionBase"
  has_many  :rules, :class_name => "FilterRule", :dependent => :destroy
  has_and_belongs_to_many :repositories, :class_name => "Repository", :uniq => true
  has_and_belongs_to_many :products, :uniq => true

  validate :validate_products_and_repos
  validates :name, :presence => true, :allow_blank => false,
              :length => { :maximum => 255 },
              :uniqueness => {:scope => :content_view_definition_id}

  def self.applicable(repo)
    query = %{filters.id in (select filter_id from  filters_repositories where repository_id = #{repo.id})
              OR filters.id in (select filter_id from  filters_products where product_id = #{repo.product_id}) }
    where(query).select("DISTINCT filters.id")
  end

  def as_json(options = {})
     super(options).update("content_view_definition_label" => content_view_definition.label,
                          "organization" => content_view_definition.organization.label,
                          "products" =>  products.collect(&:name),
                          "repos" => repositories.collect(&:name),
                          "rules" => rules)
  end

  def validate_filter_products_and_repos(errors, cvd)
    prod_diff = self.products - cvd.resulting_products
    repo_diff = self.repositories - cvd.repos
    unless prod_diff.empty?
      errors.add(:base, _("cannot contain filters whose products do not belong to this content view definition"))
    end
    unless repo_diff.empty?
      errors.add(:base, _("cannot contain filters whose repositories do not belong to this content view definition"))
    end
  end

  def clone_for_archive
    filter = Filter.new(:name => self.name)
    filter.content_view_definition_id = nil
    filter.products = self.products
    filter.repositories = self.repositories
    if Rails.version >= "3.1"
      filter.rules = self.rules.map(&:dup)
    else
      filter.rules = self.rules.map(&:clone)
    end

    filter
  end

  protected

  def validate_products_and_repos
    validate_filter_products_and_repos(self.errors, self.content_view_definition)
  end

end
