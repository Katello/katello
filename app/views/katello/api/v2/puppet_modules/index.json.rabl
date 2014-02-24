# In this index.json.rabl, we are purposely not using the
# 'katello/api/v2/common/index' as that assumes this index
# will only be used from the package groups controller; however,
# we'll also utilize it elsewhere (e.g. content views controller).

object false

extends "katello/api/v2/common/metadata"

child @collection[:results] => :results do
  extends("katello/api/v2/puppet_modules/show")
end
