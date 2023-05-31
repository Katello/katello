module Katello
  class ContentViewModuleStreamFilterRule < Katello::Model
    include ::Katello::Concerns::ContentViewFilterRuleCommon
    belongs_to :filter,
               :class_name => "Katello::ContentViewModuleStreamFilter",
               :inverse_of => :module_stream_rules,
               :foreign_key => :content_view_filter_id
    belongs_to :module_stream, :class_name => "Katello::ModuleStream", :inverse_of => :rules
    validates :module_stream_id, :presence => true, :uniqueness => { :scope => :content_view_filter_id }

    def self.in_content_views(content_view_ids)
      joins('INNER JOIN katello_content_view_filters ON katello_content_view_module_stream_filter_rules.content_view_filter_id = katello_content_view_filters.id').
        where("katello_content_view_filters.content_view_id IN (#{content_view_ids.join(',')})")
    end
  end
end
