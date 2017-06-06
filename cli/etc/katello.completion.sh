#
# Katello bash completion script
#
# vim:ts=2:sw=2:et:
#

_katello() {
  # we have to sed out utf characters produced by the python completer so that they don't appear on not utf ready terminals
  COMPREPLY=($(_complete_katello "${COMP_WORDS[*]}" | sed -e 's/^[^a-z \-]\+\w//' -e 's/^[ ]*//'))
  return 0
}

complete -F _katello katello
