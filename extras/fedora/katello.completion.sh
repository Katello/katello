#
# Katello bash completion script
#
# vim:ts=2:sw=2:et:
#

# options common to all subcommands (+ 3rd level opts for simplicity)
_katello_common_opts="-g -v --help
--id --repo --org --name --prior --product --repo_id --description --environment
--url --type --file --username --password --disabled"

# complete functions for subcommands ($1 - current opt, $2 - previous opt)
_katello_distribution()
{
  local opts="info list
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_environment()
{
  local opts="create info list update delete
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_errata()
{
  local opts="info list
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_org()
{
  local opts="create info list update delete
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_user()
{
  local opts="create info list update delete
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))
}

_katello_package()
{
  local opts="info list
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_product()
{
  local opts="create list synchronize promote
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_provider()
{
  local opts="create info list update delete sync import_manifest
  ${_katello_common_opts}"
  case "${2}" in
    --file)
      opts=$(for F in "${1}*.zip"; do echo "$F"; done)
  esac
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_repo()
{
  local opts="list status info
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_system()
{
  local opts="list register
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_template()
{
  local opts="create list info
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

# main complete function
_katello()
{
  local first cur prev opts base
  COMPREPLY=()
  first=${COMP_WORDS[1]}
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  # top-level commands and options
  opts="-u -p -h --host --help 
  distribution environment errata org package ping product provider repo shell system template"

  case "${first}" in
    distribution|\
      environment|\
      errata|\
      org|\
      user|\
      package|\
      ping|\
      product|\
      provider|\
      repo|\
      system|\
      template)
      "_katello_$first" "${cur}" "${prev}"
      return 0
      ;;
    *)
      ;;
  esac

  COMPREPLY=($(compgen -W "${opts}" -- ${cur}))  
  return 0
}

complete -F _katello katello
