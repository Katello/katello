module Katello
  class ContentSearch::SearchUtils
    cattr_accessor :current_organization, :env_ids, :offset, :current_user

    class << self
      delegate :page_size, :to => :current_user
    end

    def self.search_envs(mode)
      if mode != 'all'
        KTEnvironment.readable.where(:id => self.env_ids)
      else
        KTEnvironment.readable
      end
    end

    def self.offset
      @@offset.to_i
    end
  end
end
