module Katello
  class ContentViewModuleStreamFilter < ContentViewFilter
    CONTENT_TYPE = ModuleStream::CONTENT_TYPE
    has_many :module_stream_rules, :dependent => :destroy, :foreign_key => :content_view_filter_id,
                             :class_name => "Katello::ContentViewModuleStreamFilterRule"

    validates_lengths_from_database

    def generate_clauses(_repo)
      return if module_stream_rules.blank?

      module_stream_ids = module_stream_rules.map(&:module_stream_id)
      module_streams_in(module_stream_ids) unless module_stream_ids.empty?
    end

    private

    def module_stream_arel
      ::Katello::ModuleStream.arel_table
    end

    def module_streams_in(ids)
      module_stream_arel[:id].in(ids)
    end
  end
end
