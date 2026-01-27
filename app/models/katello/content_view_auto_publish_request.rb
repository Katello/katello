module Katello
  class ContentViewAutoPublishRequest < ApplicationRecord
    belongs_to :content_view
    belongs_to :content_view_version

    validates :content_view, presence: true
    validates :content_view_version, presence: true
  end
end
