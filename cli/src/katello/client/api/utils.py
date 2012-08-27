#
# Katello Repos actions
# Copyright (c) 2012 Red Hat, Inc.
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

"""
Bunch of api utilities for finding records by their names.
Katello API uses integer ids for record identification in most
cases. These util functions help with translating names to ids.
All of them throw ApiDataError if any of the records is not found.
"""


from gettext import gettext as _
from katello.client.api.organization import OrganizationAPI
from katello.client.api.environment import EnvironmentAPI
from katello.client.api.product import ProductAPI
from katello.client.api.repo import RepoAPI
from katello.client.api.provider import ProviderAPI
from katello.client.api.template import TemplateAPI
from katello.client.api.changeset import ChangesetAPI
from katello.client.api.user import UserAPI
from katello.client.api.user_role import UserRoleAPI
from katello.client.api.sync_plan import SyncPlanAPI
from katello.client.api.permission import PermissionAPI
from katello.client.api.filter import FilterAPI
from katello.client.api.system_group import SystemGroupAPI
from katello.client.api.system import SystemAPI


class ApiDataError(Exception):
    """
    Exception to indicate an error in search for data via api.
    The only argument is the error message.

    :argument: localized error message
    """
    pass


def get_organization(orgName):
    organization_api = OrganizationAPI()

    org = organization_api.organization(orgName)
    if org == None:
        raise ApiDataError(_("Could not find organization [ %s ]") % orgName)

    return org


def get_environment(orgName, envName=None):
    environment_api = EnvironmentAPI()

    if envName == None:
        env = environment_api.library_by_org(orgName)
        envName = env['name']
    else:
        env = environment_api.environment_by_name(orgName, envName)

    if env == None:
        raise ApiDataError(_("Could not find environment [ %s ] within organization [ %s ]") %
            (envName, orgName))
    return env


def get_library(orgName):
    return get_environment(orgName, None)


def get_product(orgName, prodName):
    product_api = ProductAPI()

    prod = product_api.product_by_name(orgName, prodName)
    if prod == None:
        raise ApiDataError(_("Could not find product [ %s ] within organization [ %s ]") %
            (prodName, orgName))
    return prod


def get_repo(orgName, prodName, repoName, envName=None, includeDisabled=False):
    repo_api = RepoAPI()

    env  = get_environment(orgName, envName)
    prod = get_product(orgName, prodName)

    repos = repo_api.repos_by_env_product(env["id"], prod["id"], repoName, includeDisabled)
    if len(repos) > 0:
        #repo by id call provides more information
        return repo_api.repo(repos[0]["id"])

    raise ApiDataError(_("Could not find repository [ %s ] within organization [ %s ], " \
        "product [ %s ] and environment [ %s ]") %
        (repoName, orgName, prodName, env["name"]))


def get_provider(orgName, provName):
    provider_api = ProviderAPI()

    prov = provider_api.provider_by_name(orgName, provName)
    if prov == None:
        raise ApiDataError(_("Could not find provider [ %s ] within organization [ %s ]") %
            (provName, orgName))
    return prov


def get_template(orgName, envName, tplName):
    template_api = TemplateAPI()

    env = get_environment(orgName, envName)
    tpl = template_api.template_by_name(env["id"], tplName)
    if tpl == None:
        raise ApiDataError(_("Could not find template [ %s ] within environment [ %s ]") %
            (tplName, env["name"]))
    return tpl


def get_changeset(orgName, envName, csName):
    changeset_api = ChangesetAPI()

    env = get_environment(orgName, envName)
    cset = changeset_api.changeset_by_name(orgName, env["id"], csName)
    if cset == None:
        raise ApiDataError(_("Could not find changeset [ %s ] within environment [ %s ]") %
            (csName, env["name"]))
    return cset

def get_user(userName):
    user_api = UserAPI()
    user = user_api.user_by_name(userName)
    if user == None:
        raise ApiDataError(_("Could not find user [ %s ]") % (userName))
    return user

def get_role(name):
    user_role_api = UserRoleAPI()
    role = user_role_api.role_by_name(name)
    if role == None:
        raise ApiDataError(_("Cannot find user role [ %s ]") % (name))
    return role

def get_sync_plan(org_name, name):
    plan_api = SyncPlanAPI()
    plan = plan_api.sync_plan_by_name(org_name, name)
    if plan == None:
        raise ApiDataError(_("Cannot find sync plan [ %s ]") % (name))
    return plan

def get_permission(role_name, permission_name):
    permission_api = PermissionAPI()

    role = get_role(role_name)

    perm = permission_api.permission_by_name(role['id'], permission_name)
    if perm == None:
        raise ApiDataError(_("Cannot find permission [ %s ] for user role [ %s ]") %
            (role_name, permission_name))
    return perm

def get_filter(org_name, name):
    filter_api = FilterAPI()
    filter = filter_api.info(org_name, name)
    if filter == None:
        raise ApiDataError(_("Cannot find filter [ %s ]") % (name))
    return filter

def get_system_group(org_name, system_group_name):
    system_group_api = SystemGroupAPI()

    system_group = system_group_api.system_group_by_name(org_name, system_group_name)
    if system_group == None:
        raise ApiDataError(_("Could not find system group [ %s ] within organization [ %s ]") % (system_group_name, org_name))
    return system_group

def get_system(org_name, sys_name, env_name=None):
    system_api = SystemAPI()
    if env_name is None:
        systems = system_api.systems_by_org(org_name, {'name': sys_name})
        if systems is None:
            raise ApiDataError(_("Could not find System [ %s ] in Org [ %s ]") % (sys_name, org_name))
        elif len(systems) != 1:
            raise ApiDataError( _("Found ambiguous Systems [ %s ] in Environment [ %s ] in Org [ %s ]") %
                (sys_name, env_name, org_name))
    else:
        environment = get_environment(org_name, env_name)
        systems = system_api.systems_by_env(environment["id"], {'name': sys_name})
        if systems is None:
            raise ApiDataError(_("Could not find System [ %s ] in Environment [ %s ] in Org [ %s ]") %
                (sys_name, env_name, org_name))
        elif len(systems) != 1:
            raise ApiDataError(_("Found ambiguous Systems [ %s ] in Org [ %s ], "\
                "you have to specify the environment") %
                (sys_name, org_name))

    return system_api.system(systems[0]['uuid'])
