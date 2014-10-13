object @resource

attributes :uuid => :id
attributes :title, :errata_id
attributes :issued, :updated
attributes :severity
attributes :_href

attributes :errata_type => :type

node(:systems_available_count) { |m| m.systems_available.count }
