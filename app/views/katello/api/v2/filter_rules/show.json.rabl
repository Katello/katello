object @resource

extends 'katello/api/v2/common/identifier'

attributes :version, :if => lambda { |rule| rule.respond_to?(:version) && !rule.version.blank? }
attributes :min_version, :if => lambda { |rule| rule.respond_to?(:min_version) && !rule.min_version.blank? }
attributes :max_version, :if => lambda { |rule| rule.respond_to?(:max_version) && !rule.max_version.blank? }

attributes :errata_id, :if => lambda { |rule| rule.respond_to?(:errata_id) && !rule.errata_id.blank? }
attributes :start_date, :if => lambda { |rule| rule.respond_to?(:start_date) && !rule.start_date.blank? }
attributes :end_date, :if => lambda { |rule| rule.respond_to?(:end_date) && !rule.end_date.blank? }
attributes :types, :if => lambda { |rule| rule.respond_to?(:types) && !rule.types.blank? }

extends 'katello/api/v2/common/timestamps'
