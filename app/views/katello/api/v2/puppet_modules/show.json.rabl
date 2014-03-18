object @resource

attributes :id
attributes :name
attributes :version
attributes :author
attributes :summary
attributes :description
attributes :license
attributes :project_page
attributes :source
attributes :dependencies
attributes :checksums
attributes :tag_list
attributes :repoids

child :repositories => :repositories do |repository|
  extends 'katello/api/v2/repositories/show'
end
