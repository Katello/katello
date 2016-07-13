module Katello
  class ContentViewComponent < Katello::Model
    self.include_root_in_json = false

    belongs_to :content_view, :class_name => "Katello::ContentView",
                              :inverse_of => :content_view_components
    belongs_to :content_view_version, :class_name => "Katello::ContentViewVersion",
                                      :inverse_of => :content_view_components

    validates_lengths_from_database
    validates :content_view_version_id, :uniqueness => {:scope => :content_view_id}
    validate :content_view_types

    private

    def content_view_types
      if content_view_version.content_view.composite?
        errors.add(:base, _("Cannot add composite versions to a composite content view"))
      end
      if content_view_version.default?
        errors.add(:base, _("Cannot add default content view to composite content view"))
      end
    end
  end
end
