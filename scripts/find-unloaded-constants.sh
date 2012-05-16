#!/bin/env bash
# Script for finding unloaded constants when reloading code in development
# environment.  When using require_dependency, rails doesn't know explicitly
# that it should unload this constants. Therefore it's preferred to use
# autoloading feature provided by Rails if possible.
#
# not unloaded constants should be listed in
# `config/initializers/mark_for_unload.rb` file to let Rails know it should
# unload it on reload.
#
# This script should be run from Rails root of the application.
#
# It returns number of unloaded constatns in the exit code so that it can be
# used in other scripts if needed.

REQS=$(grep -Phor "require_dependency ['\"]\K.*(?=['\"])" . | sort | uniq)

SUM=0
for req in $REQS; do
    OUT=$(cat <<EOF | rails c | grep '^ '
reload!
x = Module.constants;require_dependency '$req'
y = Module.constants
reload!
z = Module.constants
puts <<EOS
\\x20=======================================
\\x20$req:
\\x20loaded constatns:       #{(y-x).inspect}
\\x20not unloaded constatns: #{(z-x).inspect}
\\x20#{(z-x).size}
EOS
EOF
)
    echo "$OUT"
    fail=$(echo "$OUT" | grep '^ [0-9]\+')
    SUM=$(($SUM + $fail))
done

exit $SUM
