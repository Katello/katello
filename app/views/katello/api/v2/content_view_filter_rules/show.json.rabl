object @resource

extends 'katello/api/v2/common/identifier'

attributes :content_view_filter_id
attributes :uuid, :if => lambda { |rule| rule.respond_to?(:uuid) && !rule.uuid.blank? }
attributes :version, :if => lambda { |rule| rule.respond_to?(:version) && !rule.version.blank? }
attributes :min_version, :if => lambda { |rule| rule.respond_to?(:min_version) && !rule.min_version.blank? }
attributes :max_version, :if => lambda { |rule| rule.respond_to?(:max_version) && !rule.max_version.blank? }

attributes :errata_id, :if => lambda { |rule| rule.respond_to?(:errata_id) && !rule.errata_id.blank? }
attributes :start_date, :if => lambda { |rule| rule.respond_to?(:start_date) && !rule.start_date.blank? }
attributes :end_date, :if => lambda { |rule| rule.respond_to?(:end_date) && !rule.end_date.blank? }
attributes :architecture, :if => lambda { |rule| rule.respond_to?(:architecture) && !rule.architecture.blank? }
attributes :types, :if => lambda { |rule| rule.respond_to?(:types) && !rule.types.blank? }
attributes :date_type, :if => lambda { |rule| rule.respond_to?(:date_type) }
attributes :module_stream_id, :if => lambda { |rule| rule.respond_to?(:module_stream_id) && !rule.module_stream_id.blank? }
if @resource&.try(:module_stream)
  node :module_stream do |rule|
    {
      :module_stream_id => rule.module_stream.id,
      :module_stream_name => rule.module_stream.name,
      :module_stream_stream => rule.module_stream.stream,
    }
  end
end
extends 'katello/api/v2/common/timestamps'
