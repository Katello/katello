#!/usr/bin/python
#
# Katello Shell
# Copyright (c) 2010 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.
#

import sys
import codecs

# Change encoding of output streams when no encoding is forced via $PYTHONIOENCODING
# or setting in lib/python{version}/site-packages
if sys.getdefaultencoding() == 'ascii':
    writer_class = codecs.getwriter('utf-8')
    if sys.stdout.encoding == None:
        sys.stdout = writer_class(sys.stdout)
    if sys.stderr.encoding == None:
        sys.stderr = writer_class(sys.stderr)


from katello.client.core import (
  activation_key,
  environment,
  organization,
  user,
  user_role,
  provider,
  ping,
  version,
  product,
  repo,
  packagegroup,
  permission,
  distribution,
  package,
  errata,
  system,
  sync_plan,
  shell_command,
  template,
  changeset,
  client,
  filters,
  gpg_key,
  system_group,
  admin
)

def setup_admin(katello_cmd):
    akey_cmd = activation_key.ActivationKey()
    akey_cmd.add_subcommand('create', activation_key.Create())
    akey_cmd.add_subcommand('info', activation_key.Info())
    akey_cmd.add_subcommand('list', activation_key.List())
    akey_cmd.add_subcommand('update', activation_key.Update())
    akey_cmd.add_subcommand('delete', activation_key.Delete())
    akey_cmd.add_subcommand('add_system_group', activation_key.AddSystemGroup())
    akey_cmd.add_subcommand('remove_system_group', activation_key.RemoveSystemGroup())
    katello_cmd.add_subcommand('activation_key', akey_cmd)

    env_cmd = environment.Environment()
    env_cmd.add_subcommand('create', environment.Create())
    env_cmd.add_subcommand('info', environment.Info())
    env_cmd.add_subcommand('list', environment.List())
    env_cmd.add_subcommand('update', environment.Update())
    env_cmd.add_subcommand('delete', environment.Delete())
    katello_cmd.add_subcommand('environment', env_cmd)

    org_cmd = organization.Organization()
    org_cmd.add_subcommand('create', organization.Create())
    org_cmd.add_subcommand('info', organization.Info())
    org_cmd.add_subcommand('list', organization.List())
    org_cmd.add_subcommand('update', organization.Update())
    org_cmd.add_subcommand('delete', organization.Delete())
    org_cmd.add_subcommand('uebercert', organization.GenerateDebugCert())
    org_cmd.add_subcommand('subscriptions', organization.ShowSubscriptions())
    katello_cmd.add_subcommand('org', org_cmd)

    user_cmd = user.User()
    user_cmd.add_subcommand('create', user.Create())
    user_cmd.add_subcommand('info', user.Info())
    user_cmd.add_subcommand('list', user.List())
    user_cmd.add_subcommand('update', user.Update())
    user_cmd.add_subcommand('delete', user.Delete())
    user_cmd.add_subcommand('report', user.Report())
    user_cmd.add_subcommand('assign_role', user.AssignRole(True))
    user_cmd.add_subcommand('unassign_role', user.AssignRole(False))
    user_cmd.add_subcommand('list_roles', user.ListRoles())
    user_cmd.add_subcommand('sync_ldap_roles', user.SyncLdapRoles())
    katello_cmd.add_subcommand('user', user_cmd)

    user_role_cmd = user_role.UserRole()
    user_role_cmd.add_subcommand('create', user_role.Create())
    user_role_cmd.add_subcommand('info', user_role.Info())
    user_role_cmd.add_subcommand('list', user_role.List())
    user_role_cmd.add_subcommand('update', user_role.Update())
    user_role_cmd.add_subcommand('add_ldap_group', user_role.AddLdapGroup())
    user_role_cmd.add_subcommand('remove_ldap_group', user_role.RemoveLdapGroup())
    user_role_cmd.add_subcommand('delete', user_role.Delete())
    katello_cmd.add_subcommand('user_role', user_role_cmd)

    permission_cmd = permission.Permission()
    permission_cmd.add_subcommand('create', permission.Create())
    permission_cmd.add_subcommand('list', permission.List())
    permission_cmd.add_subcommand('delete', permission.Delete())
    permission_cmd.add_subcommand('available_verbs', permission.ListAvailableVerbs())
    katello_cmd.add_subcommand('permission', permission_cmd)

    katello_cmd.add_subcommand('ping', ping.Status())
    katello_cmd.add_subcommand('version', version.Info())

    prod_cmd = product.Product()
    prod_cmd.add_subcommand('create', product.Create())
    prod_cmd.add_subcommand('update', product.Update())
    prod_cmd.add_subcommand('list', product.List())
    prod_cmd.add_subcommand('delete', product.Delete())
    prod_cmd.add_subcommand('synchronize', product.Sync())
    prod_cmd.add_subcommand('cancel_sync', product.CancelSync())
    prod_cmd.add_subcommand('status', product.Status())
    prod_cmd.add_subcommand('promote', product.Promote())
    prod_cmd.add_subcommand('list_filters', product.ListFilters())
    prod_cmd.add_subcommand('add_filter', product.AddRemoveFilter(True))
    prod_cmd.add_subcommand('remove_filter', product.AddRemoveFilter(False))
    prod_cmd.add_subcommand('set_plan', product.SetSyncPlan())
    prod_cmd.add_subcommand('remove_plan', product.RemoveSyncPlan())
    katello_cmd.add_subcommand('product', prod_cmd)

    repo_cmd = repo.Repo()
    repo_cmd.add_subcommand('create', repo.Create())
    repo_cmd.add_subcommand('update', repo.Update())
    repo_cmd.add_subcommand('discover', repo.Discovery())
    repo_cmd.add_subcommand('info', repo.Info())
    repo_cmd.add_subcommand('list', repo.List())
    repo_cmd.add_subcommand('delete', repo.Delete())
    repo_cmd.add_subcommand('status', repo.Status())
    repo_cmd.add_subcommand('synchronize', repo.Sync())
    repo_cmd.add_subcommand('cancel_sync', repo.CancelSync())
    repo_cmd.add_subcommand('enable', repo.Enable(True))
    repo_cmd.add_subcommand('disable', repo.Enable(False))
    repo_cmd.add_subcommand('list_filters', repo.ListFilters())
    repo_cmd.add_subcommand('add_filter', repo.AddRemoveFilter(True))
    repo_cmd.add_subcommand('remove_filter', repo.AddRemoveFilter(False))

    katello_cmd.add_subcommand('repo', repo_cmd)

    package_group_cmd = packagegroup.PackageGroup()
    package_group_cmd.add_subcommand('list', packagegroup.List())
    package_group_cmd.add_subcommand('info', packagegroup.Info())
    package_group_cmd.add_subcommand('category_list', packagegroup.CategoryList())
    package_group_cmd.add_subcommand('category_info', packagegroup.CategoryInfo())
    katello_cmd.add_subcommand('package_group',package_group_cmd)

    dist_cmd = distribution.Distribution()
    dist_cmd.add_subcommand('info', distribution.Info())
    dist_cmd.add_subcommand('list', distribution.List())
    katello_cmd.add_subcommand('distribution', dist_cmd)

    pack_cmd = package.Package()
    pack_cmd.add_subcommand('info', package.Info())
    pack_cmd.add_subcommand('list', package.List())
    pack_cmd.add_subcommand('search', package.Search())
    katello_cmd.add_subcommand('package', pack_cmd)

    errata_cmd = errata.Errata()
    errata_cmd.add_subcommand('list', errata.List())
    errata_cmd.add_subcommand('info', errata.Info())
    errata_cmd.add_subcommand('system', errata.SystemErrata())
    katello_cmd.add_subcommand('errata', errata_cmd)

    system_cmd = system.System()
    system_cmd.add_subcommand('list', system.List())
    system_cmd.add_subcommand('register', system.Register())
    system_cmd.add_subcommand('unregister', system.Unregister())
    system_cmd.add_subcommand('subscriptions', system.Subscriptions())
    system_cmd.add_subcommand('subscribe', system.Subscribe())
    system_cmd.add_subcommand('unsubscribe', system.Unsubscribe())
    system_cmd.add_subcommand('info', system.Info())
    system_cmd.add_subcommand('packages', system.InstalledPackages())
    system_cmd.add_subcommand('facts', system.Facts())
    system_cmd.add_subcommand('update', system.Update())
    system_cmd.add_subcommand('report', system.Report())
    system_cmd.add_subcommand('tasks', system.TasksList())
    system_cmd.add_subcommand('task', system.TaskInfo())
    system_cmd.add_subcommand('releases', system.Releases())
    system_cmd.add_subcommand('add_to_groups', system.AddSystemGroups())
    system_cmd.add_subcommand('remove_from_groups', system.RemoveSystemGroups())
    system_cmd.add_subcommand('remove_deletion', system.RemoveDeletion())
    katello_cmd.add_subcommand('system', system_cmd)

    system_group_cmd = system_group.SystemGroup()
    system_group_cmd.add_subcommand('list', system_group.List())
    system_group_cmd.add_subcommand('info', system_group.Info())
    system_group_cmd.add_subcommand('job_history', system_group.History())
    system_group_cmd.add_subcommand('job_tasks', system_group.HistoryTasks())
    system_group_cmd.add_subcommand('systems', system_group.Systems())
    system_group_cmd.add_subcommand('add_systems', system_group.AddSystems())
    system_group_cmd.add_subcommand('remove_systems', system_group.RemoveSystems())
    system_group_cmd.add_subcommand('lock', system_group.Lock())
    system_group_cmd.add_subcommand('unlock', system_group.Unlock())
    system_group_cmd.add_subcommand('create', system_group.Create())
    system_group_cmd.add_subcommand('update', system_group.Update())
    system_group_cmd.add_subcommand('delete', system_group.Delete())
    katello_cmd.add_subcommand('system_group', system_group_cmd)

    sync_plan_cmd = sync_plan.SyncPlan()
    sync_plan_cmd.add_subcommand('create', sync_plan.Create())
    sync_plan_cmd.add_subcommand('info', sync_plan.Info())
    sync_plan_cmd.add_subcommand('list', sync_plan.List())
    sync_plan_cmd.add_subcommand('update', sync_plan.Update())
    sync_plan_cmd.add_subcommand('delete', sync_plan.Delete())
    katello_cmd.add_subcommand('sync_plan', sync_plan_cmd)

    template_cmd = template.Template()
    template_cmd.add_subcommand('create', template.Create())
    template_cmd.add_subcommand('import', template.Import())
    template_cmd.add_subcommand('export', template.Export())
    template_cmd.add_subcommand('list', template.List())
    template_cmd.add_subcommand('info', template.Info())
    template_cmd.add_subcommand('update', template.Update())
    template_cmd.add_subcommand('delete', template.Delete())
    katello_cmd.add_subcommand('template', template_cmd)

    katello_cmd.add_subcommand('shell', shell_command.ShellAction(katello_cmd))

    prov_cmd = provider.Provider()
    prov_cmd.add_subcommand('create', provider.Update(create=True))
    prov_cmd.add_subcommand('info', provider.Info())
    prov_cmd.add_subcommand('list', provider.List())
    prov_cmd.add_subcommand('update', provider.Update())
    prov_cmd.add_subcommand('delete', provider.Delete())
    prov_cmd.add_subcommand('synchronize', provider.Sync())
    prov_cmd.add_subcommand('cancel_sync', provider.CancelSync())
    prov_cmd.add_subcommand('status', provider.Status())
    prov_cmd.add_subcommand('import_manifest', provider.ImportManifest())
    prov_cmd.add_subcommand('refresh_products', provider.RefreshProducts())
    katello_cmd.add_subcommand('provider', prov_cmd)

    cset_cmd = changeset.Changeset()
    cset_cmd.add_subcommand('create', changeset.Create())
    cset_cmd.add_subcommand('list', changeset.List())
    cset_cmd.add_subcommand('info', changeset.Info())
    cset_cmd.add_subcommand('update', changeset.UpdateContent())
    cset_cmd.add_subcommand('delete', changeset.Delete())
    cset_cmd.add_subcommand('promote', changeset.Promote())
    katello_cmd.add_subcommand('changeset', cset_cmd)

    client_cmd = client.Client()
    client_cmd.add_subcommand('remember', client.Remember())
    client_cmd.add_subcommand('forget', client.Forget())
    client_cmd.add_subcommand('saved_options', client.SavedOptions())
    katello_cmd.add_subcommand('client', client_cmd)

    filter_cmd = filters.Filter()
    filter_cmd.add_subcommand('create', filters.Create())
    filter_cmd.add_subcommand('list', filters.List())
    filter_cmd.add_subcommand('info', filters.Info())
    filter_cmd.add_subcommand('delete', filters.Delete())
    filter_cmd.add_subcommand('add_package', filters.AddPackage())
    filter_cmd.add_subcommand('remove_package', filters.RemovePackage())
    katello_cmd.add_subcommand('filter', filter_cmd)

    gpgkey_cmd = gpg_key.GpgKey()
    gpgkey_cmd.add_subcommand('create', gpg_key.Create())
    gpgkey_cmd.add_subcommand('info', gpg_key.Info())
    gpgkey_cmd.add_subcommand('list', gpg_key.List())
    gpgkey_cmd.add_subcommand('update', gpg_key.Update())
    gpgkey_cmd.add_subcommand('delete', gpg_key.Delete())
    katello_cmd.add_subcommand('gpg_key', gpgkey_cmd)

    admin_cmd = admin.Admin()
    admin_cmd.add_subcommand('crl_regen', admin.CrlRegen())
    katello_cmd.add_subcommand('admin', admin_cmd)

