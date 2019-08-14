module Katello
  class ContentViewModuleStreamFilterRule < Katello::Model
    include ::Katello::Concerns::ContentViewFilterRuleCommon
    belongs_to :filter,
               :class_name => "Katello::ContentViewModuleStreamFilter",
               :inverse_of => :module_stream_rules,
               :foreign_key => :content_view_filter_id

    validates :name, :presence => true, :uniqueness => { :scope => [:stream, :content_view_filter_id] }
    validates :stream, :presence => true
  end
end
