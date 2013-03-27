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


class ContentViewDefinition < ContentViewDefinitionBase
  include Glue::ElasticSearch::ContentViewDefinition if Katello.config.use_elasticsearch
  include Ext::LabelFromName
  include Authorization::ContentViewDefinition
  include AsyncOrchestration

  has_many :content_views, :dependent => :destroy
  has_many :content_view_definition_archives, :foreign_key => :source_id
  alias :archives :content_view_definition_archives

  validates :label, :uniqueness => {:scope => :organization_id},
    :presence => true
  validates :name, :presence => true, :uniqueness => {:scope => :organization_id}
  validate :validate_content
  validate :validate_filters

  validates_with Validators::KatelloNameFormatValidator, :attributes => :name
  validates_with Validators::KatelloLabelFormatValidator, :attributes => :label

  scope :composite, where(:composite=>true)
  scope :non_composite, where(:composite=>false)

  def publish(name, description, label=nil, options = { })
    options = { :async => true, :notify => false }.merge options

    view = ContentView.create!(:name => name,
                        :label=>label,
                        :description => description,
                        :content_view_definition => self,
                        :organization => organization
                       )

    version = ContentViewVersion.new(:version=>1, :content_view=>view)
    version.environments << organization.library
    version.save!

    if options[:async]
      async_task = self.async(:organization => self.organization,
                              :task_type => TaskStatus::TYPES[:content_view_publish][:type]).
                        generate_repos(view, options[:notify])

      version.task_status = async_task
      version.save!
    else
      version.task_status = nil
      version.save!
      generate_repos(view, options[:notify])
    end

    view
  end

  def generate_repos(view, notify = false)
    # general publish clone algorithm
    # Copy all rpms over
    # Copy all errata over
    # Copy all pkg groups over
    # Copy all distro over
    # Start Filtering errata in the copied
    # Start Filtering package groups in the copied repo
    # Start Filtering packages in the copied repo
    # Remove all empty errata
    # Remove all empty package groups
    # update search indices for package and errata



    async_tasks = []
    cloned_repos = []

    # Copy all rpms over
    # Copy all errata over
    # Copy all pkg groups over
    # Copy all distro over
    repos.each do |repo|
      clone = repo.create_clone(self.organization.library, view)
      async_tasks << repo.clone_contents(clone)
      cloned_repos << clone
    end
    PulpTaskStatus::wait_for_tasks async_tasks.flatten(1)


    # Start Filtering errata in the copied
    # Start Filtering package groups in the copied repo
    # Start Filtering packages in the copied repo
    cloned_repos.each do |repo|
      [FilterRule::ERRATA, FilterRule::PACKAGE_GROUP, FilterRule::PACKAGE].each do |content_type|
        filter_clauses = generate_unassociate_filter_clauses(repo.library_instance, content_type)
        if filter_clauses
          pulp_task = repo.unassociate_by_filter(content_type, filter_clauses)
          PulpTaskStatus::wait_for_tasks [pulp_task]
        end
      end
    end

    # TODO find a quick way to remove empty errata and package groups
    # Remove all errata with no packages
    # Remove all  package groups with no packages

    #TODO


    # update search indices for package and errata
    cloned_repos.each do |repo|
      repo.index_errata
      repo.index_packages
    end


    if notify
      message = _("Successfully published content view '%{view_name}' from definition '%{definition_name}'.") %
          {:view_name => view.name, :definition_name => self.name}

      Notify.success(message, :request_type => "content_view_definitions___publish",
                     :organization => self.organization)
    end

  rescue => e
    Rails.logger.error(e)
    Rails.logger.error(e.backtrace.join("\n"))

    if notify
      message = _("Failed to publish content view '%{view_name}' from definition '%{definition_name}'.") %
          {:view_name => view.name, :definition_name => self.name}


      Notify.exception(message, e, :request_type => "content_view_definitions___publish",
                       :organization => self.organization)
    end

    raise e
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
        prod_repos = prod.repos(organization.library).enabled
        prod_repos.select{|r| r.in_default_view?}.each{|r| repos << r}
      end
      repos.concat(self.repositories)
      repos.uniq!
    end
    repos
  end

  def resulting_products
    (self.products + self.repositories.collect{|r| r.product}).uniq
  end

  def has_content?
    self.products.any? || self.repositories.any?
  end

  def has_promoted_views?
    !! self.content_views.promoted.first
  end

  def has_repo_conflicts?
    # Check to see if there is a repo conflict in the component views associated with
    # the definition.  A conflict exists if the same repo exists in more than
    # one of those component views.
    if self.composite?
      repos_hash = self.views_repos
      repos_hash.each do |view_id, repo_ids|
        repos_hash.each do |other_view_id, other_repo_ids|
          return true if (view_id != other_view_id) && !repo_ids.intersection(other_repo_ids).empty?
        end
      end
    end
    false
  end

  def as_json(options = {})
    result = self.attributes
    result["organization"] = self.organization.try(:name)
    result["content_views"] = self.content_views.map(&:name)
    result["components"] = self.component_content_views.map(&:name)
    result["products"] = products.map(&:name)
    result["repos"] = repositories.map(&:name)
    result
  end

  def archive
    excluded = ["type", "created_at", "updated_at"]
    cvd_archive = ContentViewDefinitionArchive.new(self.attributes.except(*excluded))

    # TODO: copy filters
    # cvd_archive.filters               = self.filters.map(&:clone)
    cvd_archive.repositories            = self.repositories
    cvd_archive.products                = self.products
    cvd_archive.component_content_views = self.component_content_views
    cvd_archive.source_id               = self.id
    cvd_archive.save!

    cvd_archive
  end

  protected

    def generate_unassociate_filter_clauses(repo, content_type)
      # find applicable filters
      # split filter rules by content type, since each content type has its own copy call
      # depending on include or exclude filters combine or remove
      applicable_filters = filters.applicable(repo)

      applicable_rules = FilterRule.where(:filter_id => applicable_filters).where(:content_type => content_type)
      #  do |f|
      #   f.repositories.include?(repo)
      # end
      filter_clauses = {}
      inclusion_rules = applicable_rules.where(:inclusion => true)
      exclusion_rules = applicable_rules.where(:inclusion => false)

      includes_count = inclusion_rules.count
      excludes_count = exclusion_rules.count

      #   If there is no include/exclude filters  -  Everything is included. - so do not delete anything
      return if includes_count == 0 && excludes_count == 0


      clauses = []
      #  If there are only exclude filters (aka blacklist filters),
      #  then unassociate them from the repo
      #
      if excludes_count > 0
        excludes = exclusion_rules.collect do |x|
          x.parameters[:units].collect do |unit|
            {'name' =>{"$regex" => unit[:name]}}
          end
        end.flatten
        clauses << {'$or' =>excludes}
      end


      #  If there are only include filters (aka whitelist) then only the packages/errata included will get included.
      #  Everything else is thus excluded.
      if includes_count > 0
        includes = inclusion_rules.collect do |x|
          x.parameters[:units].collect do |unit|
            {'name' =>{"$regex" => unit[:name]}}
          end
        end.flatten
        clauses << {'$nor' => includes}
      end

      #    If there are include and exclude filters, the exclude filters then the include filters, get processed first,
      #       then the exclude filter excludes content from the set included by the include filters.
=begin
      package_clauses = []
      if includes_count > 0
        includes = applicable_rules.includes.collect{|x| {'name' =>{"$regex" => x.parameters[:name]}}}
        package_clauses << {'$or' =>includes}
      end

      if excludes_count > 0
        excludes = applicable_rules.excludes.collect{|x| {'name' =>{"$regex" => x.parameters[:name]}}}
        package_clauses << {'$nor' => excludes}
      end

=end
      case clauses.size
        when 1
           return clauses.first
         when 2
           return {'$or' => clauses}
         else
           #ignore
      end
  end

  def views_repos
    # Retrieve a hash where, key=view.id and value=Set(view's repo library instance ids)
    self.component_content_views.inject({}) do |view_repos, view|
      view_repos.update view.id => view.repos(self.organization.library).
          inject(Set.new) { |ids, repo| ids << repo.library_instance_id }
    end
  end

  private

  def validate_content
    if has_content? && self.composite?
      errors.add(:base, _("cannot contain products, or repositories if it contains views"))
    end
  end

  def validate_filters
    filters.each do |f|
      f.validate_filter_products_and_repos(self.errors, self)
      break if errors.any?
    end
  end

  def remove_product(product)
    filters.each do |f|
      modified = false
      if f.products.include? product
        f.products.delete(product)
        modified = true
      end
      repos_to_remove = f.repositories.select{|r| r.product == product}
      f.repositories -= repos_to_remove
      f.save! if modified || repos_to_remove.size > 0
    end
  end

  def remove_repository(repository)
    filters.each do |f|
      if f.repositories.include? repository
        f.repositories.delete(repository)
        f.save!
      end
      # if i am removing the last repository of this product from the definition
      #     and there is a filter that includes the product,  remove it from the filter
      if self.repositories.in_product(repository.product).empty? &&
              f.products.include?(repository.product)
        f.products.delete(repository.product)
        f.save!
      end
    end
  end

end
