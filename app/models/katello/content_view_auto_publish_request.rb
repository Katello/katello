module Katello
  class ContentViewAutoPublishRequest < ApplicationRecord
    include ForemanTasks::Concerns::ActionSubject

    belongs_to :content_view
    belongs_to :content_view_version

    validates :content_view, presence: true
    validates :content_view_version, presence: true

    # Satisfy ActionSubject
    def name
      "Fake"
    end
  end
end
