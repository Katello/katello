module Katello
  class ContentViewVersionExportHistory < Katello::Model
    include Authorization::ContentViewVersionExportHistory

    belongs_to :content_view_version, :class_name => "Katello::ContentViewVersion", :inverse_of => :export_histories
    validates_lengths_from_database
    validates :content_view_version_id, :presence => true
    validates :destination_server, :presence => true, :uniqueness => { :scope => [:content_view_version_id, :destination_server, :path] }
    validates :metadata, :presence => true
    serialize :metadata, Hash

    scope :with_organization_id, ->(organization_id) do
      where(:content_view_version_id => ContentViewVersion.with_organization_id(organization_id))
    end

    scope :with_content_view_id, ->(cv_id) do
      where(:content_view_version_id => ContentViewVersion.where(content_view_id: cv_id))
    end

    scoped_search :on => :content_view_id, :relation => :content_view_version, :validator => ScopedSearch::Validators::INTEGER, :only_explicit => true
    scoped_search :on => :content_view_version_id, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :on => :id, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
  end
end
