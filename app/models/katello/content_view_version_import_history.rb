module Katello
  class ContentViewVersionImportHistory < Katello::Model
    include Authorization::ContentViewVersionImportHistory
    include Concerns::AuditCommentExtensions

    audited except: :metadata
    delegate :organization, to: :content_view_version
    delegate :id, to: :organization, prefix: true

    belongs_to :content_view_version, :class_name => "::Katello::ContentViewVersion", :inverse_of => :import_histories
    validates_lengths_from_database

    validates :content_view_version_id, presence: true
    validates :metadata, presence: true
    validates :path, presence: true
    serialize :metadata, Hash

    before_validation do |history|
      history.import_type = ContentViewVersionExportHistory.export_type_from_metadata(history.metadata)
    end

    scope :with_organization_id, ->(organization_id) do
      where(:content_view_version_id => ContentViewVersion.with_organization_id(organization_id))
    end

    scope :with_content_view_id, ->(cv_id) do
      where(:content_view_version_id => ContentViewVersion.where(content_view_id: cv_id))
    end

    scoped_search :on => :content_view_id, :relation => :content_view_version, :validator => ScopedSearch::Validators::INTEGER, :only_explicit => true
    scoped_search :on => :content_view_version_id, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :on => :id, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :on => :import_type, :rename => :type, :complete_value => ContentViewVersionExportHistory::EXPORT_TYPES

    def self.generate_audit_comment(user:, content_view_name:)
      truncate_audit_comment(_("Content imported by %{user} into content view '%{name}'") % {
        user: user.to_label,
        name: content_view_name
      })
    end
  end
end
