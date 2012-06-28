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
    akey_cmd.add_command('create', activation_key.Create())
    akey_cmd.add_command('info', activation_key.Info())
    akey_cmd.add_command('list', activation_key.List())
    akey_cmd.add_command('update', activation_key.Update())
    akey_cmd.add_command('delete', activation_key.Delete())
    akey_cmd.add_command('add_system_group', activation_key.AddSystemGroup())
    akey_cmd.add_command('remove_system_group', activation_key.RemoveSystemGroup())
    katello_cmd.add_command('activation_key', akey_cmd)

    env_cmd = environment.Environment()
    env_cmd.add_command('create', environment.Create())
    env_cmd.add_command('info', environment.Info())
    env_cmd.add_command('list', environment.List())
    env_cmd.add_command('update', environment.Update())
    env_cmd.add_command('delete', environment.Delete())
    katello_cmd.add_command('environment', env_cmd)

    org_cmd = organization.Organization()
    org_cmd.add_command('create', organization.Create())
    org_cmd.add_command('info', organization.Info())
    org_cmd.add_command('list', organization.List())
    org_cmd.add_command('update', organization.Update())
    org_cmd.add_command('delete', organization.Delete())
    org_cmd.add_command('uebercert', organization.GenerateDebugCert())
    org_cmd.add_command('subscriptions', organization.ShowSubscriptions())
    katello_cmd.add_command('org', org_cmd)

    user_cmd = user.User()
    user_cmd.add_command('create', user.Create())
    user_cmd.add_command('info', user.Info())
    user_cmd.add_command('list', user.List())
    user_cmd.add_command('update', user.Update())
    user_cmd.add_command('delete', user.Delete())
    user_cmd.add_command('report', user.Report())
    user_cmd.add_command('assign_role', user.AssignRole(True))
    user_cmd.add_command('unassign_role', user.AssignRole(False))
    user_cmd.add_command('list_roles', user.ListRoles())
    user_cmd.add_command('sync_ldap_roles', user.SyncLdapRoles())
    katello_cmd.add_command('user', user_cmd)

    user_role_cmd = user_role.UserRole()
    user_role_cmd.add_command('create', user_role.Create())
    user_role_cmd.add_command('info', user_role.Info())
    user_role_cmd.add_command('list', user_role.List())
    user_role_cmd.add_command('update', user_role.Update())
    user_role_cmd.add_command('add_ldap_group', user_role.AddLdapGroup())
    user_role_cmd.add_command('remove_ldap_group', user_role.RemoveLdapGroup())
    user_role_cmd.add_command('delete', user_role.Delete())
    katello_cmd.add_command('user_role', user_role_cmd)

    permission_cmd = permission.Permission()
    permission_cmd.add_command('create', permission.Create())
    permission_cmd.add_command('list', permission.List())
    permission_cmd.add_command('delete', permission.Delete())
    permission_cmd.add_command('available_verbs', permission.ListAvailableVerbs())
    katello_cmd.add_command('permission', permission_cmd)

    katello_cmd.add_command('ping', ping.Status())
    katello_cmd.add_command('version', version.Info())

    prod_cmd = product.Product()
    prod_cmd.add_command('create', product.Create())
    prod_cmd.add_command('update', product.Update())
    prod_cmd.add_command('list', product.List())
    prod_cmd.add_command('delete', product.Delete())
    prod_cmd.add_command('synchronize', product.Sync())
    prod_cmd.add_command('cancel_sync', product.CancelSync())
    prod_cmd.add_command('status', product.Status())
    prod_cmd.add_command('promote', product.Promote())
    prod_cmd.add_command('list_filters', product.ListFilters())
    prod_cmd.add_command('add_filter', product.AddRemoveFilter(True))
    prod_cmd.add_command('remove_filter', product.AddRemoveFilter(False))
    prod_cmd.add_command('set_plan', product.SetSyncPlan())
    prod_cmd.add_command('remove_plan', product.RemoveSyncPlan())
    katello_cmd.add_command('product', prod_cmd)

    repo_cmd = repo.Repo()
    repo_cmd.add_command('create', repo.Create())
    repo_cmd.add_command('update', repo.Update())
    repo_cmd.add_command('discover', repo.Discovery())
    repo_cmd.add_command('info', repo.Info())
    repo_cmd.add_command('list', repo.List())
    repo_cmd.add_command('delete', repo.Delete())
    repo_cmd.add_command('status', repo.Status())
    repo_cmd.add_command('synchronize', repo.Sync())
    repo_cmd.add_command('cancel_sync', repo.CancelSync())
    repo_cmd.add_command('enable', repo.Enable(True))
    repo_cmd.add_command('disable', repo.Enable(False))
    repo_cmd.add_command('list_filters', repo.ListFilters())
    repo_cmd.add_command('add_filter', repo.AddRemoveFilter(True))
    repo_cmd.add_command('remove_filter', repo.AddRemoveFilter(False))

    katello_cmd.add_command('repo', repo_cmd)

    package_group_cmd = packagegroup.PackageGroup()
    package_group_cmd.add_command('list', packagegroup.List())
    package_group_cmd.add_command('info', packagegroup.Info())
    package_group_cmd.add_command('category_list', packagegroup.CategoryList())
    package_group_cmd.add_command('category_info', packagegroup.CategoryInfo())
    katello_cmd.add_command('package_group',package_group_cmd)

    dist_cmd = distribution.Distribution()
    dist_cmd.add_command('info', distribution.Info())
    dist_cmd.add_command('list', distribution.List())
    katello_cmd.add_command('distribution', dist_cmd)

    pack_cmd = package.Package()
    pack_cmd.add_command('info', package.Info())
    pack_cmd.add_command('list', package.List())
    pack_cmd.add_command('search', package.Search())
    katello_cmd.add_command('package', pack_cmd)

    errata_cmd = errata.Errata()
    errata_cmd.add_command('list', errata.List())
    errata_cmd.add_command('info', errata.Info())
    errata_cmd.add_command('system', errata.SystemErrata())
    errata_cmd.add_command('system_group', errata.SystemGroupErrata())
    katello_cmd.add_command('errata', errata_cmd)

    system_cmd = system.System()
    system_cmd.add_command('list', system.List())
    system_cmd.add_command('register', system.Register())
    system_cmd.add_command('unregister', system.Unregister())
    system_cmd.add_command('subscriptions', system.Subscriptions())
    system_cmd.add_command('subscribe', system.Subscribe())
    system_cmd.add_command('unsubscribe', system.Unsubscribe())
    system_cmd.add_command('info', system.Info())
    system_cmd.add_command('packages', system.InstalledPackages())
    system_cmd.add_command('facts', system.Facts())
    system_cmd.add_command('update', system.Update())
    system_cmd.add_command('report', system.Report())
    system_cmd.add_command('tasks', system.TasksList())
    system_cmd.add_command('task', system.TaskInfo())
    system_cmd.add_command('releases', system.Releases())
    system_cmd.add_command('add_to_groups', system.AddSystemGroups())
    system_cmd.add_command('remove_from_groups', system.RemoveSystemGroups())
    system_cmd.add_command('remove_deletion', system.RemoveDeletion())
    katello_cmd.add_command('system', system_cmd)

    system_group_cmd = system_group.SystemGroup()
    system_group_cmd.add_command('list', system_group.List())
    system_group_cmd.add_command('info', system_group.Info())
    system_group_cmd.add_command('job_history', system_group.History())
    system_group_cmd.add_command('job_tasks', system_group.HistoryTasks())
    system_group_cmd.add_command('systems', system_group.Systems())
    system_group_cmd.add_command('add_systems', system_group.AddSystems())
    system_group_cmd.add_command('remove_systems', system_group.RemoveSystems())
    system_group_cmd.add_command('lock', system_group.Lock())
    system_group_cmd.add_command('unlock', system_group.Unlock())
    system_group_cmd.add_command('create', system_group.Create())
    system_group_cmd.add_command('update', system_group.Update())
    system_group_cmd.add_command('delete', system_group.Delete())
    system_group_cmd.add_command('packages', system_group.Packages())
    system_group_cmd.add_command('errata', system_group.Errata())
    katello_cmd.add_command('system_group', system_group_cmd)

    sync_plan_cmd = sync_plan.SyncPlan()
    sync_plan_cmd.add_command('create', sync_plan.Create())
    sync_plan_cmd.add_command('info', sync_plan.Info())
    sync_plan_cmd.add_command('list', sync_plan.List())
    sync_plan_cmd.add_command('update', sync_plan.Update())
    sync_plan_cmd.add_command('delete', sync_plan.Delete())
    katello_cmd.add_command('sync_plan', sync_plan_cmd)

    template_cmd = template.Template()
    template_cmd.add_command('create', template.Create())
    template_cmd.add_command('import', template.Import())
    template_cmd.add_command('export', template.Export())
    template_cmd.add_command('list', template.List())
    template_cmd.add_command('info', template.Info())
    template_cmd.add_command('update', template.Update())
    template_cmd.add_command('delete', template.Delete())
    katello_cmd.add_command('template', template_cmd)

    katello_cmd.add_command('shell', shell_command.ShellAction(katello_cmd))

    prov_cmd = provider.Provider()
    prov_cmd.add_command('create', provider.Update(create=True))
    prov_cmd.add_command('info', provider.Info())
    prov_cmd.add_command('list', provider.List())
    prov_cmd.add_command('update', provider.Update())
    prov_cmd.add_command('delete', provider.Delete())
    prov_cmd.add_command('synchronize', provider.Sync())
    prov_cmd.add_command('cancel_sync', provider.CancelSync())
    prov_cmd.add_command('status', provider.Status())
    prov_cmd.add_command('import_manifest', provider.ImportManifest())
    prov_cmd.add_command('refresh_products', provider.RefreshProducts())
    katello_cmd.add_command('provider', prov_cmd)

    cset_cmd = changeset.Changeset()
    cset_cmd.add_command('create', changeset.Create())
    cset_cmd.add_command('list', changeset.List())
    cset_cmd.add_command('info', changeset.Info())
    cset_cmd.add_command('update', changeset.UpdateContent())
    cset_cmd.add_command('delete', changeset.Delete())
    cset_cmd.add_command('promote', changeset.Promote())
    katello_cmd.add_command('changeset', cset_cmd)

    client_cmd = client.Client()
    client_cmd.add_command('remember', client.Remember())
    client_cmd.add_command('forget', client.Forget())
    client_cmd.add_command('saved_options', client.SavedOptions())
    katello_cmd.add_command('client', client_cmd)

    filter_cmd = filters.Filter()
    filter_cmd.add_command('create', filters.Create())
    filter_cmd.add_command('list', filters.List())
    filter_cmd.add_command('info', filters.Info())
    filter_cmd.add_command('delete', filters.Delete())
    filter_cmd.add_command('add_package', filters.AddPackage())
    filter_cmd.add_command('remove_package', filters.RemovePackage())
    katello_cmd.add_command('filter', filter_cmd)

    gpgkey_cmd = gpg_key.GpgKey()
    gpgkey_cmd.add_command('create', gpg_key.Create())
    gpgkey_cmd.add_command('info', gpg_key.Info())
    gpgkey_cmd.add_command('list', gpg_key.List())
    gpgkey_cmd.add_command('update', gpg_key.Update())
    gpgkey_cmd.add_command('delete', gpg_key.Delete())
    katello_cmd.add_command('gpg_key', gpgkey_cmd)

    admin_cmd = admin.Admin()
    admin_cmd.add_command('crl_regen', admin.CrlRegen())
    katello_cmd.add_command('admin', admin_cmd)
