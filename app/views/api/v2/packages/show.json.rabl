object @resource

attributes :_id => :id
attributes :_content_type_id => :content_type_id
attributes :name, :description, :epoch, :checksum, :arch, :version 
attributes :license, :filename, :buildhost, :vendor, :relativepath
attributes :children, :release, :checksumtype, :checksum, :repoids

node :provides do |res|
	res.provides.map { |e| { :feature => { :name => e[0], :comparator => e[1], :version => e[2] } } }
end

node :requires do |res|
	res.requires.map { |e| { :feature => { :name => e[0], :comparator => e[1], :version => e[2] } } }
end
