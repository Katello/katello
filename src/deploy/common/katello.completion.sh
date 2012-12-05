#
# Katello bash completion script
#
# vim:ts=2:sw=2:et:
#

_katello() {
  COMPREPLY=($(_complete_katello "${COMP_WORDS[*]}" | sed 's/^[^a-z\-]*\w//'))
  return 0
}

complete -F _katello katello
