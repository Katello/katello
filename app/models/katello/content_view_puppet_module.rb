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
    scoped_search :on => :name, :relation => :content_view, :rename => :content_view_name

    def puppet_module
      PuppetModule.find_by_uuid(self.uuid)
    end

    def computed_version
      if self.uuid
        puppet_module = PuppetModule.where(:uuid => self.uuid).first
      else
        puppet_module = PuppetModule.latest_module(
          self.name,
          self.author,
          self.content_view.puppet_repos
        )
      end

      puppet_module.try(:version)
    end

    before_save :set_attributes

    private

    def set_attributes
      return unless SETTINGS[:katello][:use_pulp]
      if self.uuid.present?
        puppet_module = PuppetModule.with_identifiers(self.uuid).first
        fail Errors::NotFound, _("Couldn't find Puppet Module with id '%s'") % self.uuid unless puppet_module

        self.name = puppet_module.name
        self.author = puppet_module.author
      end
    end
  end
end
