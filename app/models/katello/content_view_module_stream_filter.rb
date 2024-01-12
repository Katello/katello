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

    def content_unit_pulp_ids(repo, dependents = false)
      content_unit_ids = []
      module_ids = []

      self.module_stream_rules.each do |rule|
        module_ids << rule.module_stream_id
      end
      if self.original_module_streams
        module_ids.concat(repo.module_streams_without_errata.map(&:id))
      end
      modules_streams = ModuleStream.in_repositories(repo).where(id: module_ids).includes(:rpms)
      content_unit_ids += modules_streams.pluck(:pulp_id).flatten.uniq
      if dependents && !modules_streams.empty?
        rpms = modules_streams.map(&:rpms).flatten
        content_unit_ids += rpms.pluck(:pulp_id).flatten.uniq
      end
      content_unit_ids.uniq
    end
  end
end
