module Katello
  class ContentSearch::MetadataRow
    include ContentSearch::Element
    attr_accessor :unique_id
    display_attributes :total, :current_count, :page_size, :data, :id, :metadata, :parent_id

    def page_size
      ContentSearch::SearchUtils.page_size
    end

    def id
      @id ||= "repo_metadata_#{unique_id}"
    end

    def metadata
      true
    end

    def data_type
      "metadata"
    end
  end
end
