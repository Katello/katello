module Katello
  module Concerns
    module SearchByRepositoryName
      extend ActiveSupport::Concern
      include ScopedSearchExtensions

      included do
        has_many :root_repositories, through: :repositories, :source => :root, class_name: "Katello::RootRepository"
        scoped_search :relation => :root_repositories, :on => :name, :rename => :repository,
                      :complete_value => true,
                      :ext_method => :search_by_repo_name, :only_explicit => true
      end

      module ClassMethods
        def search_by_repo_name(_key, operator, value)
          conditions = sanitize_sql_for_conditions(["#{Katello::RootRepository.table_name}.name #{operator} ?", value_to_sql(operator, value)])
          query = self.joins(:repositories => :root).where(conditions).select('id')
          {:conditions => "#{self.table_name}.id IN (#{query.to_sql})"}
        end
      end
    end
  end
end
