module Katello
  class ContentViewHistory < Katello::Model
    include Katello::Authorization::ContentViewHistory

    belongs_to :environment, :class_name => "Katello::KTEnvironment", :inverse_of => :content_view_histories,
                             :foreign_key => :katello_environment_id
    belongs_to :content_view_version, :class_name => "Katello::ContentViewVersion", :foreign_key => :katello_content_view_version_id, :inverse_of => :history

    belongs_to :triggered_by, :class_name => "Katello::ContentViewVersion", :inverse_of => :triggered_histories

    belongs_to :task, :class_name => "ForemanTasks::Task::DynflowTask"

    IN_PROGRESS = 'in progress'.freeze
    FAILED = 'failed'.freeze
    SUCCESSFUL = 'successful'.freeze
    STATUSES = [IN_PROGRESS, FAILED, SUCCESSFUL].freeze

    validates_lengths_from_database
    validates :status, :inclusion => {:in => STATUSES,
                                      :allow_blank => false}
    validates :action, presence: true

    scope :active, -> { where(:status => IN_PROGRESS) }
    scope :successful, -> { where(:status => SUCCESSFUL) }
    alias_method :version, :content_view_version
    alias_attribute :description, :notes

    scoped_search :on => :id, :relation => :content_view_version, :rename => :content_view_version_id
    scoped_search :on => :name, :relation => :environment, :rename => :environment, :complete_value => true

    enum action: {
      publish: 1,
      promotion: 2,
      removal: 3,
      export: 4,
      importing: 5,
    }

    def content_view
      self.content_view_version.try(:content_view)
    end

    def self.in_organization(organization)
      content_views = ContentView.where(:organization_id => organization.id)

      self.joins(:content_view_version => :content_view).
          where("#{ContentView.table_name}.id" => content_views).
          order("#{self.table_name}.updated_at DESC")
    end

    def self.in_organizations(organizations)
      content_views = ContentView.where(:organization_id => organizations)

      self.joins(:content_view_version => :content_view).
          where("#{ContentView.table_name}.id" => content_views).
          order("#{self.table_name}.updated_at DESC")
    end

    def humanized_action
      if export?
        _("Exported version")
      elsif publish?
        _("Published new version")
      elsif promotion?
        _("Promoted to %{environment}") % { :environment => self.environment.try(:name) || _('Unknown') }
      elsif removal?
        _("Deleted from %{environment}") % { :environment => self.environment.try(:name) || _('Unknown')}
      else
        _("Unknown Action")
      end
    end

    def humanized_status
      case self.status
      when ContentViewHistory::IN_PROGRESS
        _("In Progress")
      when ContentViewHistory::FAILED
        _("Failed")
      when ContentViewHistory::SUCCESSFUL
        _("Success")
      end
    end
  end
end
