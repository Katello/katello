module Katello
  class ComponentViewPresenter < SimpleDelegator
    attr_accessor :view, :component_view

    def initialize(cv, content_view)
      @view = content_view
      @component_view = Katello::ContentViewComponent.where(:composite_content_view_id => cv.id, :content_view_id => @view.id).first_or_initialize
      super(@component_view)
    end

    def self.component_presenter(cv, views:)
      views.map { |content_view| ComponentViewPresenter.new(cv, content_view) }
    end
  end
end
