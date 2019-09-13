module Katello
  class ContentViewModuleStreamFilter < ContentViewFilter
    CONTENT_TYPE = ModuleStream::CONTENT_TYPE
    has_many :module_stream_rules, :dependent => :destroy, :foreign_key => :content_view_filter_id,
                             :class_name => "Katello::ContentViewModuleStreamFilterRule"

    validates_lengths_from_database

    def generate_clauses(_repo)
      return if module_stream_rules.blank?
      module_stream_rules.map(&:module_stream_id)
    end
  end
end
