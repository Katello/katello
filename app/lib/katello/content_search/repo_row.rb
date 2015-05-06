module Katello
  class ContentSearch::RepoRow < ContentSearch::Row
    attr_accessor :repo

    def initialize(options)
      super
      build_row
    end

    def build_row
      self.data_type ||= "repo"
      self.cols ||= {}
      self.id ||= build_id
      self.name ||= @repo.name
    end

    def build_id
      [parent_id, data_type, repo.id].select(&:present?).join("_")
    end
  end
end
