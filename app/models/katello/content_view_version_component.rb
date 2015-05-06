module Katello
  class ContentViewVersionComponent < Katello::Model
    belongs_to :composite_version, :class_name => "Katello::ContentViewVersion", :inverse_of => :content_view_version_components, :inverse_of =>  :content_view_version_composites
    belongs_to :component_version, :class_name => "Katello::ContentViewVersion", :inverse_of => :content_view_version_composites, :inverse_of => :content_view_version_components

    validates_lengths_from_database
    validate :content_view_types

    private

    def content_view_types
      unless composite_version.content_view.composite?
        errors.add(:base, _("Cannot add component versions to a non-composite content view"))
      end

      if component_version.content_view.composite?
        errors.add(:base, _("Cannot add composite versions to another composite content view"))
      end

      if composite_version.default? || component_version.default?
        errors.add(:base, _("Cannot add default content view to composite content view"))
      end
    end
  end
end
