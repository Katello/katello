module Katello
  class ContentViewComponent < Katello::Model
    include Authorization::ContentViewComponent

    audited :associated_with => :composite_content_view
    belongs_to :composite_content_view, :class_name => "Katello::ContentView",
                              :inverse_of => :content_view_components
    belongs_to :content_view_version, :class_name => "Katello::ContentViewVersion",
                              :inverse_of => :content_view_components
    belongs_to :content_view, :class_name => "Katello::ContentView",
                              :inverse_of => :component_composites

    validates_lengths_from_database

    validates :composite_content_view, :presence => true
    validate :ensure_valid_attributes
    validate :ensure_valid_content_view

    before_validation :update_content_view, :on => :create

    scoped_search :on => :name, :relation => :content_view, :complete_value => true
    scoped_search :on => :organization_id, :relation => :content_view, :complete_value => true, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :on => :label, :relation => :content_view, :complete_value => true
    scoped_search :on => :composite, :relation => :content_view, :complete_value => true

    def latest_version
      if latest?
        self.content_view.latest_version_object
      else
        self.content_view_version
      end
    end

    def component_content_view_versions
      self.content_view&.versions&.order(created_at: :desc)
    end

    private

    def ensure_valid_content_view
      view = content_view || content_view_version.try(:content_view)
      return unless view

      if content_view_version.present? && view.id != content_view_version.content_view_id
        errors.add(:base, _("Invalid association of the content view id. Content View must match the content view version being saved"))
      end

      if view.composite?
        errors.add(:base, _("Cannot add composite versions to a composite content view"))
      end

      if view.default?
        errors.add(:base, _("Cannot add default content view to composite content view"))
      end

      if view.rolling?
        errors.add(:base, _("Cannot add rolling content view to composite content view"))
      end

      if attached_content_view_ids.include?(view.id)
        errors.add(:base, _("Another component already includes content view with ID %s" % view.id))
      end

      unless view.generated_for_none?
        errors.add(:base, _("Cannot add generated content view versions to composite content view"))
      end
    end

    def ensure_valid_attributes
      if !(content_view.present? || content_view_version.present?)
        errors.add(:base, _("Either set the content view with the latest flag or set the content view version"))
      elsif !composite_content_view.composite?
        errors.add(:base, _("Cannot associate a component to a non composite content view"))
      elsif latest?
        if content_view_version.present?
          errors.add(:base, _("Either set the latest content view or the content view version. Cannot set both"))
        end
      elsif content_view_version.nil?
        errors.add(:base, _("Content View Version not set"))
      end
    end

    def attached_content_view_ids
      composite_content_view.content_view_components.map do |cvc|
        next if cvc == self
        if cvc.content_view_version
          cvc.content_view_version.content_view_id
        else
          cvc.content_view_id
        end
      end
    end

    def update_content_view
      if content_view_version.present? && content_view.blank?
        self.content_view = content_view_version.content_view
      end
    end
  end
end
