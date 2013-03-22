object @resource

extends 'api/v2/errata/_attributes'

child Util::Data::ostructize(@object.pkglist) => :pkglist do
  attributes :short, :name
  child :packages => :packages do
    attributes :version, :arch, :release, :src, :filename, :epoch, :name
  end
end
