collection Util::Data::ostructize(@resource.map{ |type, details| details.merge({ :type => type }) }), :object_root => "resource_type"

attributes :type, :name, :tags, :no_tag_verbs, :global, :verbs
