#
# This group file is not distributed as RPM (but used during build or dev phase).
#
group :build do
  unless defined? JRUBY_VERSION
    # for apipie (it is in default group)
    gem 'redcarpet'
  end
end

group :ci do
  # needed by hudson
  gem 'ci_reporter', '~> 1.7.2', :require => false
end
