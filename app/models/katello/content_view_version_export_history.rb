module Katello
  class ContentViewVersionExportHistory < Katello::Model
    include Authorization::ContentViewVersionExportHistory
    audited except: :metadata
    delegate :organization, to: :content_view_version
    delegate :id, to: :organization, prefix: true

    COMPLETE = "complete".freeze
    INCREMENTAL = "incremental".freeze
    EXPORT_TYPES = [COMPLETE, INCREMENTAL].freeze

    belongs_to :content_view_version, :class_name => "::Katello::ContentViewVersion", :inverse_of => :export_histories
    validates_lengths_from_database

    validates :content_view_version_id, :presence => true
    validates :destination_server, :uniqueness => { :scope => [:content_view_version_id, :destination_server, :path] }
    validates :export_type, :presence => true,
              :inclusion => { :in => EXPORT_TYPES,
                              :allow_blank => false,
                              :message => _("must be one of the following: %s" % EXPORT_TYPES.join(', '))
                            }
    validates :metadata, :presence => true
    serialize :metadata, Hash

    before_validation :set_export_type

    scope :with_organization_id, ->(organization_id) do
      where(:content_view_version_id => ContentViewVersion.with_organization_id(organization_id))
    end

    scope :with_content_view_id, ->(cv_id) do
      where(:content_view_version_id => ContentViewVersion.where(content_view_id: cv_id))
    end

    scoped_search :on => :content_view_id, :relation => :content_view_version, :validator => ScopedSearch::Validators::INTEGER, :only_explicit => true
    scoped_search :on => :content_view_version_id, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :on => :id, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :on => :export_type, :rename => :type, :complete_value => EXPORT_TYPES

    def self.latest(content_view, destination_server: nil)
      where(content_view_version: content_view.versions,
            destination_server: destination_server).order(:created_at).last
    end

    def self.export_type_from_metadata(metadata)
      metadata[:incremental] ? INCREMENTAL : COMPLETE
    end

    def set_export_type
      self.export_type ||= self.class.export_type_from_metadata(metadata)
    end

    def self.generate_audit_comment(user:, content_view_version:, from_version: nil, metadata:)
      export_type = export_type_from_metadata(metadata)
      if content_view_version.content_view.generated_for_library?
        export_descriptor = "library export"
      elsif content_view_version.content_view.generated_for_repository?
        export_descriptor = "repository export"
      else
        export_descriptor = "export of content view '#{content_view_version.content_view.name}' version #{content_view_version.version}"
        export_descriptor += " from #{from_version.name}" if from_version
      end
      "#{export_type&.capitalize} #{export_descriptor} created by #{user.to_label}"
    end
  end
end
