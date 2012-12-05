#
# This group file is not distributed as RPM (but used during build phase).
#
group :build do
  unless defined? JRUBY_VERSION
    # for apipie (it is in default group)
    gem 'redcarpet'
  end
end

