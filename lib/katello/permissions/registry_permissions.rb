require 'katello/plugin.rb'

Foreman::AccessControl.permission(:create_personal_access_tokens).actions.concat [
  'katello/api/registry/registry_proxies/token',
  'katello/api/registry/registry_proxies/v1_ping',
  'katello/api/registry/registry_proxies/ping',
  'katello/api/registry/registry_proxies/v1_search',
  'katello/api/registry/registry_proxies/catalog',
  'katello/api/registry/registry_proxies/tags_list',
  'katello/api/registry/registry_proxies/pull_manifest',
  #'katello/api/registry/registry_proxies/push_manifest',
  'katello/api/registry/registry_proxies/pull_blob',
  'katello/api/registry/registry_proxies/check_blob',
  #'katello/api/registry/registry_proxies/start_upload_blob',
  #'katello/api/registry/registry_proxies/upload_blob',
  #'katello/api/registry/registry_proxies/chunk_upload_blob',
  #'katello/api/registry/registry_proxies/finish_upload_blob',
  'katello/api/registry/registry_proxies/status_upload_blob',
  'katello/api/registry/registry_proxies/cancel_upload_blob'
]
