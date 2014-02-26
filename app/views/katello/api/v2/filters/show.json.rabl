object @resource

extends 'katello/api/v2/common/identifier'

node(:type) { |filter| filter.type.constantize::CONTENT_TYPE }
attributes :inclusion

child :content_view => :content_view do
  extends 'katello/api/v2/content_views/show'
end

child :repositories => :repositories do
  attributes :id, :name, :label
end

node :rules,
     :if => lambda { |filter| (filter.respond_to?(:package_rules) && !filter.package_rules.blank?) ||
                              (filter.respond_to?(:package_group_rules) && !filter.package_group_rules.blank?) ||
                              (filter.respond_to?(:erratum_rules) && !filter.erratum_rules.blank?) } do |filter|
  if filter.respond_to?(:package_rules)
    filter.package_rules.map do |rule|
      partial('katello/api/v2/filter_rules/show', :object => rule)
    end

  elsif filter.respond_to?(:package_group_rules)
    filter.package_group_rules.map do |rule|
      partial('katello/api/v2/filter_rules/show', :object => rule)
    end

  else # :erratum_rule
    filter.erratum_rules.map do |rule|
      partial('katello/api/v2/filter_rules/show', :object => rule)
    end
  end
end

extends 'katello/api/v2/common/timestamps'
