object false

extends "katello/api/v2/common/metadata"

sorted = @collection[:results].sort_by { 
  |v| Gem::Version.new(v['version'])
}.reverse!

child :sorted do
  extends 'katello/api/v2/ostree_branches/show'
end
