object @resource

extends 'katello/api/v2/common/identifier'

node(:type) { |filter| filter.class::CONTENT_TYPE }
attributes :inclusion

child :content_view => :content_view do
  extends 'katello/api/v2/content_views/base'
end

child :repositories => :repositories do
  extends 'katello/api/v2/repositories/base'
end

if @resource.respond_to?(:package_rules)
  attributes :original_packages
end

if @resource.respond_to?(:module_stream_rules)
  attributes :original_module_streams
end

node :rules do |filter|
  if filter.respond_to?(:package_rules)
    filter.package_rules.map do |rule|
      partial('katello/api/v2/content_view_filter_rules/show', :object => rule)
    end

  elsif filter.respond_to?(:package_group_rules)
    filter.package_group_rules.map do |rule|
      partial('katello/api/v2/content_view_filter_rules/show', :object => rule)
    end

  elsif filter.respond_to?(:erratum_rules)
    filter.erratum_rules.map do |rule|
      partial('katello/api/v2/content_view_filter_rules/show', :object => rule)
    end

  elsif filter.respond_to?(:module_stream_rules)
    filter.module_stream_rules.map do |rule|
      partial('katello/api/v2/content_view_filter_rules/show', :object => rule)
    end

  elsif filter.respond_to?(:docker_rules)
    filter.docker_rules.map do |rule|
      partial('katello/api/v2/content_view_filter_rules/show', :object => rule)
    end

  elsif filter.respond_to?(:deb_rules)
    filter.deb_rules.map do |rule|
      partial('katello/api/v2/content_view_filter_rules/show', :object => rule)
    end

  else
    []
  end
end

extends 'katello/api/v2/common/timestamps'
