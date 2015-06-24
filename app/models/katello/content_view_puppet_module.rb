module Katello
  class ContentViewPuppetModule < Katello::Model
    self.include_root_in_json = false

    belongs_to :content_view, :class_name => "Katello::ContentView", :inverse_of => :content_view_versions

    validates_lengths_from_database
    validates :content_view_id, :presence => true
    validates :name, :uniqueness => { :scope => :content_view_id }, :allow_blank => true
    validates :uuid, :uniqueness => { :scope => :content_view_id }, :allow_blank => true

    validates_with Validators::ContentViewPuppetModuleValidator

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :author, :complete_value => true
    scoped_search :on => :uuid, :complete_value => true
    scoped_search :on => :name, :in => :content_view, :rename => :content_view_name

    def puppet_module
      PuppetModule.find(self.uuid)
    end

    def computed_version
      computed_version = nil
      if Katello.config.use_elasticsearch
        names_and_authors = [{:name => self.name, :author => self.author}]
        search = PuppetModule.latest_modules_search(names_and_authors,
                                           self.content_view.organization.library.repositories.puppet_type.map(&:pulp_id))
        computed_version = search[0].version
      end
      computed_version
    end

    before_save :set_attributes

    private

    def set_attributes
      return unless Katello.config.use_pulp
      if self.uuid.present?
        puppet_module = PuppetModule.find(self.uuid)
        fail Errors::NotFound, _("Couldn't find Puppet Module with id '%s'") % self.uuid unless puppet_module

        self.name = puppet_module.name
        self.author = puppet_module.author
      elsif (self.name.present? && !self.author.present?)
        puppet_modules = PuppetModule.latest_modules_search(
          [{:name => self.name, :author => '*'}],
          self.content_view.puppet_repos.map(&:pulp_id))

        if puppet_modules.empty?
          fail Errors::NotFound, _("Couldn't find Puppet Module '%s'.") % self.name
        elsif puppet_modules.length > 1
          fail Errors::NotFound, _("Puppet Module '%s' found more than once. Please specify the author.") % self.name
        else
          self.author = puppet_modules.first.author
        end
      end
    end
  end
end
