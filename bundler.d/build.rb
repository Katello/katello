#
# This group file is not distributed as RPM (but used during build or dev phase).
#
group :build do
  # for apipie (it is in default group)
  gem 'maruku'
end

group :ci do
  # needed by hudson
  # ENGINIFY
  #gem 'ci_reporter', '~> 1.7.2', :require => false
end
