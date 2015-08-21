module Katello
  class ContentViewHistory < Katello::Model
    include Glue::ElasticSearch::ContentViewHistory if Katello.config.use_elasticsearch

    belongs_to :environment, :class_name => "Katello::KTEnvironment", :inverse_of => :content_view_histories,
                             :foreign_key => :katello_environment_id
    belongs_to :content_view_version, :class_name => "Katello::ContentViewVersion", :foreign_key => :katello_content_view_version_id, :inverse_of => :history
    belongs_to :task, :class_name => "ForemanTasks::Task::DynflowTask", :foreign_key => :task_id

    IN_PROGRESS = 'in progress'
    FAILED = 'failed'
    SUCCESSFUL = 'successful'
    STATUSES = [IN_PROGRESS, FAILED, SUCCESSFUL]

    validates_lengths_from_database
    validates :status, :inclusion => {:in          => STATUSES,
                                      :allow_blank => false}

    scope :active, -> { where(:status => IN_PROGRESS) }
    alias_method :version, :content_view_version

    def content_view
      self.content_view_version.try(:content_view)
    end
  end
end
