# In this index.json.rabl, we are purposely not using the
# 'katello/api/v2/common/index' as that assumes this index
# will only be used from the errata controller; however,
# we'll also utilize it elsewhere (e.g. filters controller).

object false

extends "katello/api/v2/common/metadata"

child @collection[:results] => :results do
  extends("katello/api/v2/errata/_attributes")
end
