object @resource

extends 'katello/api/v2/common/identifier'

attributes :content_view_filter_id
attributes :uuid
attributes :version
attributes :min_version
attributes :max_version

attributes :errata_id
attributes :start_date
attributes :end_date
attributes :architecture
attributes :types
attributes :date_type

extends 'katello/api/v2/common/timestamps'
