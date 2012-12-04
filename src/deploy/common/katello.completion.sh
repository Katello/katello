#
# Katello bash completion script
#
# vim:ts=2:sw=2:et:
#

# options common to all subcommands (+ 3rd level opts for simplicity)
_katello_common_opts="ACME_Corporation -g -v --help
--id --repo --org --name --prior --product --repo_id --description --environment
--url --type --file --username --password --disabled"

# complete functions for subcommands ($1 - current opt, $2 - previous opt)
_katello_activation_key()
{
  local opts="add_system_group create delete info list remove_system_group update
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_admin()
{
  local opts="crl_regen
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_architecture()
{
  local opts="create delete info list update
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_changeset()
{
  local opts="apply create list info update delete promote
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_client()
{
  local opts="forget remember saved_options
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_config_template()
{
  local opts="build_pxe_default create delete info list update
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_distribution()
{
  local opts="info list
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_domain()
{
  local opts="create delete info list update
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
  local opts="info list system system_group
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_filter()
{
  local opts="add_package create delete info list remove_package update
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_gpg_key()
{
  local opts="create delete info list update
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_org()
{
  local opts="add_default_system_info apply_default_system_info 
              create info list update delete remove_default_system_info 
              subscriptions uebercert
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_package()
{
  local opts="info list search
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_package_group()
{
  local opts="category_info category_list info list
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_permission()
{
  local opts="available_verbs create delete list
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_product()
{
  local opts="add_filter cancel_sync create delete list synchronize promote list_filters promote remove_filters remove_plan set_plan status update
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_provider()
{
  local opts="create info list update delete sync import_manifest cancel_sync refresh_product status synchornize
  ${_katello_common_opts}"
  case "${2}" in
    --file)
      opts=$(for F in "${1}*.zip"; do echo "$F"; done)
  esac
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_repo()
{
  local opts="add_filter cancel_sync create delete disable discover enable info list
              list_filters remove_filter status synchronize update
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_shell()
{
  COMPREPLY=($(compgen))
}

_katello_subnet()
{
  local opts="create delete info list update
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_sync_plan()
{
  local opts="create delete info list update
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_system()
{
  local opts="add_custom_info add_to_groups facts info list register packages releases
              remove_custom_info remove_deletion remove_from_groups report subscribe
              subscriptions task tasks unregister unsubscribe update update_custom_info
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_system_group()
{
  local opts="add_systems copy create delete errata info job_history job_tasks list packages
              remove_systems systems update
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_template()
{
  local opts="create delete export import info list update
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))  
}

_katello_user()
{
  local opts="assign_role create delete info list list_roles 
              report sync_ldap_roles unassign_role update
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))
}

_katello_user_role()
{
  local opts="add_ldap_group create delete info list remove_ldap_group update
  ${_katello_common_opts}"
  COMPREPLY=($(compgen -W "${opts}" -- ${1}))
}

_katello_version()
{
  COMPREPLY=($(compgen))
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
  activation_key admin architecture changeset client config_template distribution 
  domain environment errata filter gpg_key org package package_group ping product 
  provider repo shell subnet sync_plan system system_group template user user_role 
  version"

  case "${first}" in
      activation_key|\
      admin|\
      architecture|\
      changeset|\
      client|\
      config_template|\
      distribution|\
      domain|\
      environment|\
      errata|\
      filter|\
      gpg_key|\
      org|\
      package|\
      package_group|\
      ping|\
      product|\
      provider|\
      repo|\
      shell|\
      subnet|\
      sync_plan|\
      system|\
      system_group|\
      template|\
      user|\
      user_role|\
      version)
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
