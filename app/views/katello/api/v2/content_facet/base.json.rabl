attributes :id, :uuid
attributes :content_view_id, :content_view_name
attributes :lifecycle_environment_id, :lifecycle_environment_name

child :content_view => :content_view do
  attributes :id, :name
end

child :lifecycle_environment => :lifecycle_environment do
  attributes :id, :name
end

node :errata_counts do |content_facet|
  errata = content_facet.installable_errata
  partial('katello/api/v2/errata/counts', :object => Katello::RelationPresenter.new(errata))
end

node :applicable_package_count do |facet|
  facet.applicable_rpms.count
end

node :upgradable_package_count do |facet|
  facet.installable_rpms.count
end
