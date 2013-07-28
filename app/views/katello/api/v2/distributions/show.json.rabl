object @resource

attributes :id, :version, :arch, :family, :variant

files = (@resource || @object).files
files = Util::Data::ostructize(files)
child files => :files do
  attributes :pkgpath, :downloadurl, :item_type, :relativepath, :size, :savepath, :filename, :checksum, :checksumtype
end
