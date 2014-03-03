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

module Katello
class Filter < Katello::Model
  self.include_root_in_json = false

  include Glue::ElasticSearch::Filter if Katello.config.use_elasticsearch

  PACKAGE         = Package::CONTENT_TYPE
  PACKAGE_GROUP   = PackageGroup::CONTENT_TYPE
  ERRATA          = Errata::CONTENT_TYPE
  CONTENT_TYPES   = [PACKAGE, PACKAGE_GROUP, ERRATA]
  CONTENT_OPTIONS = { _('Packages') => PACKAGE, _('Package Groups') => PACKAGE_GROUP, _('Errata') => ERRATA }

  belongs_to :content_view,
             :class_name => "Katello::ContentView",
             :inverse_of => :filters

  # rubocop:disable HasAndBelongsToMany
  # TODO: change these into has_many :through associations
  has_and_belongs_to_many :repositories,
                          :uniq => true,
                          :class_name => "Katello::Repository",
                          :join_table => :katello_filters_repositories

  serialize :parameters, Hash
  validates_with Validators::SerializedParamsValidator, :attributes => :parameters

  validate :validate_content_view
  validate :validate_repos
  validates :name, :presence => true, :allow_blank => false,
            :uniqueness => { :scope => :content_view_id }
  validates_with Validators::KatelloNameFormatValidator, :attributes => :name

  scope :whitelist, where(:inclusion => true)
  scope :blacklist, where(:inclusion => false)

  scope :yum, where(:type => [PackageGroupFilter.name, ErratumFilter.name, PackageFilter.name])

  def params_format
    {}
  end

  def parameters
    write_attribute(:parameters, {}) unless self[:parameters]
    self[:parameters]
  end

  def content_type
    {
      PackageFilter => PACKAGE,
      ErratumFilter => ERRATA,
      PackageGroupFilter => PACKAGE_GROUP
    }[self.class]
  end

  def self.class_for(content_type)
    case content_type
    when PACKAGE
      PackageFilter
    when PACKAGE_GROUP
      PackageGroupFilter
    when ERRATA
      ErratumFilter
    else
      params = { :content_type => content_type, :content_types => CONTENT_TYPES.join(", ") }
      fail _("Invalid content type '%{ content_type }' provided. Content types can be one of %{ content_types }") % params
    end
  end

  def self.rule_class_for(filter)
    case filter.type
    when PackageFilter.name
      PackageFilterRule
    when PackageGroupFilter.name
      PackageGroupFilterRule
    when ErratumFilter.name
      ErratumFilterRule
    else
      params = { :content_type => filter.type, :content_types => CONTENT_TYPES.join(", ") }
      fail _("Invalid content type '%{ content_type }' provided. Content types can be one of %{ content_types }") % params
    end
  end

  def self.rule_ids_for(filter)
    case filter.type
    when PackageFilter.name
      filter.package_rule_ids
    when PackageGroupFilter.name
      filter.package_group_rule_ids
    when ErratumFilter.name
      filter.erratum_rule_ids
    else
      params = { :content_type => filter.type, :content_types => CONTENT_TYPES.join(", ") }
      fail _("Invalid content type '%{ content_type }' provided. Content types can be one of %{ content_types }") % params
    end
  end

  def filter_type
    CONTENT_OPTIONS.key(content_type)
  end

  def self.create_for(content_type, options)
    clazz = class_for(content_type)
    clazz.create!(options)
  end

  def self.applicable(repo)
    query = %{ (katello_filters.id in (select filter_id from katello_filters_repositories where repository_id = #{repo.id})) or
               (katello_filters.id not in (select filter_id from katello_filters_repositories))
             }
    where(query).select("DISTINCT katello_filters.id")
  end

  def as_json(options = {})
    super(options).update("content_view_label" => content_view.label,
                          "organization" => content_view.organization.label,
                          "repos" => repositories.collect(&:name),
                          "content" => content_type,
                          "parameters" => parameters)
  end

  def validate_content_view
    if self.content_view.composite?
      errors.add(:base, _("cannot contain filters if composite view"))
    end
  end

  def validate_filter_repos(errors, content_view)
    repo_diff = repositories - content_view.repositories
    unless repo_diff.empty?
      errors.add(:base, _("cannot contain filters whose repositories do not belong to this content view"))
    end
  end

  def resulting_products
    repositories.collect{|r| r.product}.uniq
  end

  def applicable_repos
    if self.repositories.blank?
      self.content_view.repositories
    else
      self.repositories
    end
  end

  protected

  def validate_repos
    validate_filter_repos(self.errors, self.content_view)
  end

  def get_created_at(previous_parameters, current_unit)
    # Check to see if the unit was previously part of the filter.
    # If it was, return the original created_at timestamp; otherwise,
    # return the current time
    found_unit = nil
    if !previous_parameters.blank? && previous_parameters.key?(:units)
      previous_parameters[:units].each do |previous_unit|
        created_at = previous_unit.delete(:created_at)
        if (previous_unit == current_unit)
          found_unit = previous_unit.merge({ :created_at => created_at })
          break
        end
      end
    end
    found_unit.nil? ? Time.zone.now : found_unit[:created_at]
  end
end
end
