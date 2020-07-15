module Katello
  class ContentViewModuleStreamFilter < ContentViewFilter
    CONTENT_TYPE = ModuleStream::CONTENT_TYPE
    has_many :module_stream_rules, :dependent => :destroy, :foreign_key => :content_view_filter_id,
                             :class_name => "Katello::ContentViewModuleStreamFilterRule"

    validates_lengths_from_database

    def generate_clauses(repo)
      rules = module_stream_rules || []
      ids = rules.map(&:module_stream_id)
      if self.original_module_streams
        ids.concat(repo.module_streams_without_errata.map(&:id))
      end
      ids
    end

    def original_module_streams=(value)
      self[:original_module_streams] = value
    end
  end
end
