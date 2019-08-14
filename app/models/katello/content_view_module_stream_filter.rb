module Katello
  class ContentViewModuleStreamFilter < ContentViewFilter
    CONTENT_TYPE = ModuleStream::CONTENT_TYPE
    has_many :module_stream_rules, :dependent => :destroy, :foreign_key => :content_view_filter_id,
                             :class_name => "Katello::ContentViewModuleStreamFilterRule"

    validates_lengths_from_database

    def generate_clauses(repo)
      return if module_stream_rules.blank?
      module_streams_in(ModuleStream.in_repositories([repo]).with_name_streams(module_stream_rules.pluck(:name, :stream)).pluck(:id))
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
