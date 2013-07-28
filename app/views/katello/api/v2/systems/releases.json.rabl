collection Util::Data::ostructize(@collection[:releases].map { |r| { :release => r } }), :object_root => :release

attributes :release

