# we mark these constants for unload to let Rails know that they should clean
# them when reloading them in development environment.
#
# Otherwise you might be getting "TypeError: superclass mismatch for class" in
# dev env.
#
# This does not affect production environment where no reloading happens.
%w[
  Candlepin Pulp Foreman HttpResource ResourcePermissions
].each {|c| ActiveSupport::Dependencies.mark_for_unload(c) }

