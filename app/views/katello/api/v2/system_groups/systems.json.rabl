collection Util::Data::ostructize(@collection.map { |s| s.merge({ :uuid => s[:id] }) }), :object_root => :system

attributes :name
attributes :uuid => :id
