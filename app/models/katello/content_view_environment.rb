module Katello
  class ContentViewEnvironment < Katello::Model
    self.include_root_in_json = false

    include ForemanTasks::Concerns::ActionSubject
    include Glue::Candlepin::Environment if SETTINGS[:katello][:use_cp]
    include Glue if SETTINGS[:katello][:use_cp]
    include Authorization::ContentViewEnvironment

    belongs_to :content_view, :class_name => "Katello::ContentView", :inverse_of => :content_view_environments
    belongs_to :environment, :class_name => "Katello::KTEnvironment", :inverse_of => :content_view_environments
    belongs_to :content_view_version, :class_name => "Katello::ContentViewVersion",
                                      :inverse_of => :content_view_environments

    validates_lengths_from_database
    validates :environment_id, uniqueness: {scope: :content_view_id}, presence: true
    validates :content_view_id, presence: true

    before_save :generate_info

    scope :non_default, -> { joins(:content_view).where("katello_content_views.default" => false) }

    def self.for_content_facets(content_facets)
      joins("INNER JOIN #{Host::ContentFacet.table_name} on #{Host::ContentFacet.table_name}.lifecycle_environment_id = #{ContentViewEnvironment.table_name}.environment_id").
          where("#{Host::ContentFacet.table_name}.content_view_id = #{Katello::ContentViewEnvironment.table_name}.content_view_id").where("#{Host::ContentFacet.table_name}.id" => content_facets).uniq
    end

    # retrieve the owning environment for this content view environment.
    def owner
      self.environment
    end

    def systems
      content_view.systems.in_environment(environment)
    end

    def activation_keys
      content_view.activation_keys.in_environment(environment)
    end

    private

    def generate_info
      self.name ||= environment.name

      if content_view.default?
        self.label ||= environment.label
        self.cp_id ||= environment.id.to_s
      else
        self.label ||= [environment.label, content_view.label].join('/')
        self.cp_id ||= [environment.id, content_view.id].join('-')
      end
    end
  end
end
