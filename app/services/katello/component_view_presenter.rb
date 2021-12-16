module Katello
  class ComponentViewPresenter < SimpleDelegator
    attr_accessor :view, :component_view

    def initialize(composite_cv, component_content_view = nil, content_view_component = nil)
      @view = component_content_view
      cv_component_record = content_view_component || Katello::ContentViewComponent.where(composite_content_view_id: composite_cv.id, content_view_id: @view.id).first
      @component_view = cv_component_record || Katello::ContentViewComponent.new(composite_content_view_id: composite_cv.id, content_view_id: @view.id, latest: true)
      super(@component_view)
    end

    def self.component_presenter(composite_cv, status, views:)
      case status
      when 'All'
        views.map { |component_content_view| ComponentViewPresenter.new(composite_cv, component_content_view) }
      when 'Added'
        added_cvs = views.map { |component_content_view| Katello::ContentViewComponent.where(composite_content_view_id: composite_cv.id, content_view_id: component_content_view.id).first }
        added_cvs.compact.map { |content_view| ComponentViewPresenter.new(composite_cv, nil, content_view) }
      when 'Not added'
        not_added_cvs = views.reject { |component_content_view| Katello::ContentViewComponent.where(composite_content_view_id: composite_cv.id, content_view_id: component_content_view.id).first }
        not_added_cvs.map { |component_content_view| ComponentViewPresenter.new(composite_cv, nil, Katello::ContentViewComponent.where(composite_content_view_id: composite_cv.id, content_view_id: component_content_view.id, latest: true).new) }
      else
        views.map { |component_content_view| ComponentViewPresenter.new(composite_cv, component_content_view) }
      end
    end
  end
end
