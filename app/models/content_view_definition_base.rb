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


class ContentViewDefinitionBase < ActiveRecord::Base
  belongs_to :organization, :inverse_of => :content_view_definitions
  has_many :content_view_definition_products, :foreign_key => "content_view_definition_id", :dependent => :destroy
  has_many :products, :through => :content_view_definition_products, :after_remove => :remove_product
  has_many :content_view_definition_repositories, :foreign_key => "content_view_definition_id", :dependent => :destroy
  has_many :repositories, :through => :content_view_definition_repositories, :after_remove => :remove_repository,
    :before_add => :validate_repos
  has_many :components, :class_name => "ComponentContentView",
    :foreign_key => "content_view_definition_id"
  has_many :component_content_views, :through => :components,
    :source => :content_view, :class_name => "ContentView", before_add: :validate_component_views
  has_many :filters, :inverse_of => :content_view_definition,
    :foreign_key => "content_view_definition_id"

  validates :organization, :presence => true

  def resulting_products
    (self.products + self.repositories.collect{|r| r.product}).uniq
  end

  # Retrieve a list of repositories associated with the definition.
  # This includes all repositories (ie. combining those that are part of products associated with the definition
  # as well as repositories that are explicitly associated with the definition).
  def repos
    repos = []
    if self.composite?
      self.component_content_views.each do |component_view|
        component_view.repos(organization.library).each{|r| repos << r}
      end
    else
      self.products.each do |prod|
        repos += prod.repos(organization.library).non_puppet.enabled.select(&:in_default_view?)
      end
      repos.concat(self.repositories)
      repos.uniq!
    end
    repos
  end

  def has_content?
    self.products.any? || self.repositories.any?
  end

  def archive?
    type =~ /Archive/
  end

  def has_component_views?
    component_content_views.any?
  end

  def puppet_repository
    repositories.detect(&:puppet?)
  end

  def puppet_repository_id
    puppet_repository.try(:id)
  end

  def puppet_repository_id=(id)
    return if repository_ids.include?(id)
    if repo = repositories.detect(&:puppet?)
      repositories.delete(repo)
    end
    repositories << Repository.puppet_type.find(id) unless id.blank?
  end

  protected

  def remove_product(product)
    filters.each do |filter_item|
      modified = false
      if filter_item.products.include? product
        filter_item.products.delete(product)
        modified = true
      end
      repos_to_remove = filter_item.repositories.select{|r| r.product == product}
      filter_item.repositories -= repos_to_remove
      filter_item.save! if modified || repos_to_remove.size > 0
    end
  end

  def remove_repository(repository)
    filters.each do |filter_item|
      repo_exists = Repository.unscoped.joins(:filters).where(
                      :filters => {:id => filter_item.id}, :id => repository.id).count
      if repo_exists
        filter_item.repositories.delete(repository)
        filter_item.save!
      end
      # if i am removing the last repository of this product from the definition
      #     and there is a filter that includes the product,  remove it from the filter
      if self.repositories.in_product(repository.product).empty? &&
          filter_item.products.include?(repository.product)
        filter_item.products.delete(repository.product)
        filter_item.save!
      end
    end
  end

  def validate_component_views(view)
    if type == "ContentViewDefinition"
      # check for repo overlap
      library_repo_ids = component_content_views.map(&:library_repo_ids).flatten + view.library_repo_ids
      if library_repo_ids.length != library_repo_ids.uniq.length
        raise Errors::ContentViewRepositoryOverlap.new(_("Definition cannot contain views with the same repositories."))
      end

      if !self.composite?
        raise Errors::ContentViewDefinitionBadContent.new(_("Definition cannot contain views if not composite definition"))
      end
    end
  end

  def validate_repos(repo)
    if type == "ContentViewDefinition"
      # TODO: check composite views
      if repositories.select(&:puppet?).length > 0 && repo.puppet?
        raise Errors::ContentViewRepositoryOverlap.new(_("Definition cannot contain more than one Puppet repository."))
      end
    end
  end
end
