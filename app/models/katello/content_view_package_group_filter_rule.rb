module Katello
  class ContentViewPackageGroupFilterRule < Katello::Model
    self.include_root_in_json = false

    include Glue::ElasticSearch::ContentViewPackageGroupFilterRule if Katello.config.use_elasticsearch

    belongs_to :filter,
               :class_name => "Katello::ContentViewPackageGroupFilter",
               :inverse_of => :package_group_rules,
               :foreign_key => :content_view_filter_id

    validates_lengths_from_database
    validates :uuid, :presence => true, :uniqueness => { :scope => :content_view_filter_id }
  end
end
