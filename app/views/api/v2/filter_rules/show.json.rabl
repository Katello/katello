object @resource

attributes :id, :filter_id
attributes :content_type => :content
attributes :parameters => :rule
attributes :inclusion
node :type do |res|
  res.inclusion ? _("includes"): _("excludes")
end
extends 'api/v2/common/timestamps'