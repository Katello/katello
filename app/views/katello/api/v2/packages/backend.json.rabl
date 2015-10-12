
attributes :description
attributes :license, :buildhost, :vendor, :relativepath
attributes :children, :checksumtype, :size, :url, :build_time, :summary, :group, :requires, :provides, :files

node :human_readable_size do |package|
  number_to_human_size(package.size) if package.size
end
