#!/usr/bin/python
#
# Katello Shell
# Copyright (c) 2012 Red Hat, Inc.
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

from katello.client.lib.control import get_katello_mode
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
  system_custom_info,
  task,
  sync_plan,
  shell_command,
  changeset,
  client,
  gpg_key,
  system_group,
  admin,
  architecture,
  config_template,
  domain,
  content,
  content_view,
  content_view_definition,
  filter as content_filter,
  subnet,
  smart_proxy,
  compute_resource,
  hardware_model
)

def setup_admin(katello_cmd, mode=get_katello_mode()):
    # pylint: disable=R0912,R0914,R0915
    # Following pylint warnings are disabled as we break them intentionally:
    #   R0912: Too many branches
    #   R0914: Too many local variables
    #   R0915: Too many statements

    akey_cmd = activation_key.ActivationKey()
    akey_cmd.add_command('create', activation_key.Create())
    akey_cmd.add_command('info', activation_key.Info())
    akey_cmd.add_command('list', activation_key.List())
    akey_cmd.add_command('update', activation_key.Update())
    akey_cmd.add_command('delete', activation_key.Delete())
    if mode == 'katello':
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
    org_cmd.add_command('subscriptions', organization.ShowSubscriptions())
    if mode == 'katello':
        org_cmd.add_command('uebercert', organization.GenerateDebugCert())
    default_info_cmd = organization.DefaultInfo()
    default_info_cmd.add_command("add", organization.AddDefaultInfo())
    default_info_cmd.add_command("remove", organization.RemoveDefaultInfo())
    default_info_cmd.add_command("apply", organization.ApplyDefaultInfo())
    org_cmd.add_command("default_info", default_info_cmd)
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
    prod_cmd.add_command('list', product.List())
    if mode == 'katello':
        prod_cmd.add_command('create', product.Create())
        prod_cmd.add_command('update', product.Update())
        prod_cmd.add_command('delete', product.Delete())
        prod_cmd.add_command('synchronize', product.Sync())
        prod_cmd.add_command('cancel_sync', product.CancelSync())
        prod_cmd.add_command('status', product.Status())
        prod_cmd.add_command('promote', product.Promote())
        prod_cmd.add_command('set_plan', product.SetSyncPlan())
        prod_cmd.add_command('remove_plan', product.RemoveSyncPlan())
        prod_cmd.add_command('repository_sets', product.ListRepositorySets())
        prod_cmd.add_command('repository_set_enable', product.EnableRepositorySet())
        prod_cmd.add_command('repository_set_disable', product.DisableRepositorySet())
    katello_cmd.add_command('product', prod_cmd)

    # these could be set in the same block but are separated
    # for clarity
    if mode == 'katello':
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
        katello_cmd.add_command('repo', repo_cmd)

    if mode == 'katello':
        package_group_cmd = packagegroup.PackageGroup()
        package_group_cmd.add_command('list', packagegroup.List())
        package_group_cmd.add_command('info', packagegroup.Info())
        package_group_cmd.add_command('category_list', packagegroup.CategoryList())
        package_group_cmd.add_command('category_info', packagegroup.CategoryInfo())
        katello_cmd.add_command('package_group', package_group_cmd)

    if mode == 'katello':
        dist_cmd = distribution.Distribution()
        dist_cmd.add_command('info', distribution.Info())
        dist_cmd.add_command('list', distribution.List())
        katello_cmd.add_command('distribution', dist_cmd)

    if mode == 'katello':
        pack_cmd = package.Package()
        pack_cmd.add_command('info', package.Info())
        pack_cmd.add_command('list', package.List())
        pack_cmd.add_command('search', package.Search())
        katello_cmd.add_command('package', pack_cmd)

    if mode == 'katello':
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
    system_cmd.add_command('facts', system.Facts())
    system_cmd.add_command('update', system.Update())
    system_cmd.add_command('report', system.Report())
    system_cmd.add_command('releases', system.Releases())
    system_cmd.add_command('remove_deletion', system.RemoveDeletion())
    if mode == 'katello':
        system_cmd.add_command('tasks', system.TasksList())
        system_cmd.add_command('task', system.TaskInfo())
        system_cmd.add_command('packages', system.InstalledPackages())
        system_cmd.add_command('add_to_groups', system.AddSystemGroups())
        system_cmd.add_command('remove_from_groups', system.RemoveSystemGroups())
    system_cmd.add_command('add_custom_info', system_custom_info.AddCustomInfo())
    system_cmd.add_command('update_custom_info', system_custom_info.UpdateCustomInfo())
    system_cmd.add_command('remove_custom_info', system_custom_info.RemoveCustomInfo())
    katello_cmd.add_command('system', system_cmd)

    if mode == 'katello':
        system_group_cmd = system_group.SystemGroup()
        system_group_cmd.add_command('list', system_group.List())
        system_group_cmd.add_command('info', system_group.Info())
        system_group_cmd.add_command('job_history', system_group.History())
        system_group_cmd.add_command('job_tasks', system_group.HistoryTasks())
        system_group_cmd.add_command('systems', system_group.Systems())
        system_group_cmd.add_command('add_systems', system_group.AddSystems())
        system_group_cmd.add_command('remove_systems', system_group.RemoveSystems())
        system_group_cmd.add_command('create', system_group.Create())
        system_group_cmd.add_command('copy', system_group.Copy())
        system_group_cmd.add_command('update', system_group.Update())
        system_group_cmd.add_command('delete', system_group.Delete())
        system_group_cmd.add_command('packages', system_group.Packages())
        system_group_cmd.add_command('errata', system_group.Errata())
        katello_cmd.add_command('system_group', system_group_cmd)

    if mode == 'katello':
        sync_plan_cmd = sync_plan.SyncPlan()
        sync_plan_cmd.add_command('create', sync_plan.Create())
        sync_plan_cmd.add_command('info', sync_plan.Info())
        sync_plan_cmd.add_command('list', sync_plan.List())
        sync_plan_cmd.add_command('update', sync_plan.Update())
        sync_plan_cmd.add_command('delete', sync_plan.Delete())
        katello_cmd.add_command('sync_plan', sync_plan_cmd)

    katello_cmd.add_command('shell', shell_command.ShellAction(katello_cmd))

    prov_cmd = provider.Provider()
    prov_cmd.add_command('info', provider.Info())
    prov_cmd.add_command('list', provider.List())
    prov_cmd.add_command('import_manifest', provider.ImportManifest())
    if mode == 'headpin':
        prov_cmd.add_command('delete_manifest', provider.DeleteManifest())
    if mode == 'katello':
        prov_cmd.add_command('create', provider.Update(create=True))
        prov_cmd.add_command('update', provider.Update())
        prov_cmd.add_command('delete', provider.Delete())
        prov_cmd.add_command('synchronize', provider.Sync())
        prov_cmd.add_command('cancel_sync', provider.CancelSync())
        prov_cmd.add_command('status', provider.Status())
        prov_cmd.add_command('refresh_products', provider.RefreshProducts())
    katello_cmd.add_command('provider', prov_cmd)

    if mode == 'katello':
        cset_cmd = changeset.Changeset()
        cset_cmd.add_command('create', changeset.Create())
        cset_cmd.add_command('list', changeset.List())
        cset_cmd.add_command('info', changeset.Info())
        cset_cmd.add_command('update', changeset.UpdateContent())
        cset_cmd.add_command('delete', changeset.Delete())
        cset_cmd.add_command('apply', changeset.Apply())
        cset_cmd.add_command('promote', changeset.Promote())
        katello_cmd.add_command('changeset', cset_cmd)

    if mode == 'katello':
        content_cmd = content.Content()
        cv_cmd = content_view.ContentView()
        cv_cmd.add_command('list', content_view.List())
        cv_cmd.add_command('info', content_view.Info())
        cv_cmd.add_command('promote', content_view.Promote())
        cv_cmd.add_command('refresh', content_view.Refresh())
        cvd_cmd = content_view_definition.ContentViewDefinition()
        cvd_cmd.add_command('list', content_view_definition.List())
        cvd_cmd.add_command('info', content_view_definition.Info())
        cvd_cmd.add_command('create', content_view_definition.Create())
        cvd_cmd.add_command('delete', content_view_definition.Delete())
        cvd_cmd.add_command('update', content_view_definition.Update())
        cvd_cmd.add_command('publish', content_view_definition.Publish())
        cvd_cmd.add_command('clone', content_view_definition.Clone())
        cvd_cmd.add_command('add_product',
                content_view_definition.AddRemoveProduct(True))
        cvd_cmd.add_command('remove_product',
                content_view_definition.AddRemoveProduct(False))
        cvd_cmd.add_command('add_repo',
                content_view_definition.AddRemoveRepo(True))
        cvd_cmd.add_command('remove_repo',
                content_view_definition.AddRemoveRepo(False))
        cvd_cmd.add_command('add_view',
                content_view_definition.AddRemoveContentView(True))
        cvd_cmd.add_command('remove_view',
                content_view_definition.AddRemoveContentView(False))

        filter_cmd = content_filter.Filter()
        filter_cmd.add_command('list', content_filter.List())
        filter_cmd.add_command('info', content_filter.Info())
        filter_cmd.add_command('create', content_filter.Create())
        filter_cmd.add_command('delete', content_filter.Delete())

        filter_cmd.add_command('add_product',
                content_filter.AddRemoveProduct(True))
        filter_cmd.add_command('remove_product',
                content_filter.AddRemoveProduct(False))


        filter_cmd.add_command('add_repo',
                content_filter.AddRemoveRepo(True))
        filter_cmd.add_command('remove_repo',
                content_filter.AddRemoveRepo(False))


        cvd_cmd.add_command("filter", filter_cmd)
        content_cmd.add_command('view', cv_cmd)
        content_cmd.add_command('definition', cvd_cmd)
        katello_cmd.add_command('content', content_cmd)

    if mode == 'katello':
        task_cmd = task.Task()
        task_cmd.add_command('status', task.Status())
        katello_cmd.add_command('task', task_cmd)

    client_cmd = client.Client()
    client_cmd.add_command('remember', client.Remember())
    client_cmd.add_command('forget', client.Forget())
    client_cmd.add_command('saved_options', client.SavedOptions())
    katello_cmd.add_command('client', client_cmd)

    if mode == 'katello':
        gpgkey_cmd = gpg_key.GpgKey()
        gpgkey_cmd.add_command('create', gpg_key.Create())
        gpgkey_cmd.add_command('info', gpg_key.Info())
        gpgkey_cmd.add_command('list', gpg_key.List())
        gpgkey_cmd.add_command('update', gpg_key.Update())
        gpgkey_cmd.add_command('delete', gpg_key.Delete())
        katello_cmd.add_command('gpg_key', gpgkey_cmd)

    if mode == 'katello':
        admin_cmd = admin.Admin()
        admin_cmd.add_command('crl_regen', admin.CrlRegen())
        katello_cmd.add_command('admin', admin_cmd)

    if mode == 'katello':
        architecture_cmd = architecture.Architecture()
        architecture_cmd.add_command('list', architecture.List())
        architecture_cmd.add_command('info', architecture.Show())
        architecture_cmd.add_command('create', architecture.Create())
        architecture_cmd.add_command('update', architecture.Update())
        architecture_cmd.add_command('delete', architecture.Delete())
        katello_cmd.add_command('architecture', architecture_cmd)

    if mode == 'katello':
        configtemplate_cmd = config_template.ConfigTemplate()
        configtemplate_cmd.add_command('list', config_template.List())
        configtemplate_cmd.add_command('info', config_template.Info())
        configtemplate_cmd.add_command('create', config_template.Create())
        configtemplate_cmd.add_command('update', config_template.Update())
        configtemplate_cmd.add_command('delete', config_template.Delete())
        configtemplate_cmd.add_command('build_pxe_default', config_template.Build_Pxe_Default())
        katello_cmd.add_command('config_template', configtemplate_cmd)

    if mode == 'katello':
        domain_cmd = domain.Domain()
        domain_cmd.add_command('list', domain.List())
        domain_cmd.add_command('info', domain.Info())
        domain_cmd.add_command('create', domain.Create())
        domain_cmd.add_command('update', domain.Update())
        domain_cmd.add_command('delete', domain.Delete())
        katello_cmd.add_command('domain', domain_cmd)

    if mode == 'katello':
        smart_proxy_cmd = smart_proxy.SmartProxy()
        smart_proxy_cmd.add_command('list', smart_proxy.List())
        smart_proxy_cmd.add_command('info', smart_proxy.Info())
        smart_proxy_cmd.add_command('create', smart_proxy.Create())
        smart_proxy_cmd.add_command('update', smart_proxy.Update())
        smart_proxy_cmd.add_command('delete', smart_proxy.Delete())
        katello_cmd.add_command('smart_proxy', smart_proxy_cmd)

    if mode == 'katello':
        subnet_cmd = subnet.Subnet()
        subnet_cmd.add_command('list', subnet.List())
        subnet_cmd.add_command('info', subnet.Info())
        subnet_cmd.add_command('create', subnet.Update(create=True))
        subnet_cmd.add_command('update', subnet.Update(create=False))
        subnet_cmd.add_command('delete', subnet.Delete())
        katello_cmd.add_command('subnet', subnet_cmd)

    if mode == 'katello':
        resource_cmd = compute_resource.ComputeResource()
        resource_cmd.add_command('list', compute_resource.List())
        resource_cmd.add_command('info', compute_resource.Info())
        resource_cmd.add_command('create', compute_resource.Create())
        resource_cmd.add_command('update', compute_resource.Update())
        resource_cmd.add_command('delete', compute_resource.Delete())
        katello_cmd.add_command('compute_resource', resource_cmd)

    if mode == 'katello':
        hardware_model_cmd = hardware_model.HardwareModel()
        hardware_model_cmd.add_command('list', hardware_model.List())
        hardware_model_cmd.add_command('info', hardware_model.Info())
        hardware_model_cmd.add_command('create', hardware_model.Create())
        hardware_model_cmd.add_command('update', hardware_model.Update())
        hardware_model_cmd.add_command('delete', hardware_model.Delete())
        katello_cmd.add_command('hw_model', hardware_model_cmd)
