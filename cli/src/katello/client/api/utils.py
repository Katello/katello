#
# Katello Repos actions
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

def get_organization(orgName):
    organization_api = OrganizationAPI()

    org = organization_api.organization(orgName)
    if org == None:
        print >> sys.stderr, _("Could not find organization [ %s ]") % orgName

    return org


def get_environment(orgName, envName=None):
    environment_api = EnvironmentAPI()

    if envName == None:
        env = environment_api.library_by_org(orgName)
        envName = env['name']
    else:
        env = environment_api.environment_by_name(orgName, envName)

    if env == None:
        print >> sys.stderr, _("Could not find environment [ %s ] within organization [ %s ]") % (envName, orgName)
    return env


def get_library(orgName):
    return get_environment(orgName, None)


def get_product(orgName, prodName):
    product_api = ProductAPI()

    prod = product_api.product_by_name(orgName, prodName)
    if prod == None:
        print >> sys.stderr, _("Could not find product [ %s ] within organization [ %s ]") % (prodName, orgName)
    return prod


def get_repo(orgName, prodName, repoName, envName=None, includeDisabled=False):
    repo_api = RepoAPI()

    env  = get_environment(orgName, envName)
    if env == None:
        return None

    prod = get_product(orgName, prodName)
    if prod == None:
        return None

    repos = repo_api.repos_by_env_product(env["id"], prod["id"], repoName, includeDisabled)
    if len(repos) > 0:
        #repo by id call provides more information
        return repo_api.repo(repos[0]["id"])

    print >> sys.stderr, _("Could not find repository [ %s ] within organization [ %s ], product [ %s ] and environment [ %s ]") % (repoName, orgName, prodName, env["name"])
    return None


def get_provider(orgName, provName):
    provider_api = ProviderAPI()

    prov = provider_api.provider_by_name(orgName, provName)
    if prov == None:
        print >> sys.stderr, _("Could not find provider [ %s ] within organization [ %s ]") % (provName, orgName)
    return prov


def get_template(orgName, envName, tplName):
    template_api = TemplateAPI()

    env = get_environment(orgName, envName)
    if env == None:
        return None

    tpl = template_api.template_by_name(env["id"], tplName)
    if tpl == None:
        print >> sys.stderr, _("Could not find template [ %s ] within environment [ %s ]") % (tplName, env["name"])
    return tpl


def get_changeset(orgName, envName, csName):
    changeset_api = ChangesetAPI()

    env = get_environment(orgName, envName)
    if env == None:
        return None

    cset = changeset_api.changeset_by_name(orgName, env["id"], csName)
    if cset == None:
        print >> sys.stderr, _("Could not find changeset [ %s ] within environment [ %s ]") % (csName, env["name"])
    return cset

def get_user(userName):
    user_api = UserAPI()
    user = user_api.user_by_name(userName)
    if user == None:
        print >> sys.stderr, _("Could not fing user [ %s ]") % (userName)
    return user

def get_role(name):
    user_role_api = UserRoleAPI()
    role = user_role_api.role_by_name(name)
    if role == None:
        print _("Cannot find user role [ %s ]") % (name)
    return role

def get_sync_plan(org_name, name):
    plan_api = SyncPlanAPI()
    plan = plan_api.sync_plan_by_name(org_name, name)
    if plan == None:
        print _("Cannot find sync plan [ %s ]") % (name)
    return plan

def get_permission(role_name, permission_name):
    permission_api = PermissionAPI()

    role = get_role(role_name)
    if role == None:
        return None

    perm = permission_api.permission_by_name(role['id'], permission_name)
    if perm == None:
        print _("Cannot find permission [ %s ] for user role [ %s ]") % (role_name, permission_name)
    return perm

def get_filter(org_name, name):
    filter_api = FilterAPI()
    filter = filter_api.info(org_name, name)
    if filter == None:
        print _("Cannot find filter [ %s ]") % (name)
    return filter

def get_system_group(org_name, system_group_name):
    system_group_api = SystemGroupAPI()

    system_group = system_group_api.system_group_by_name(org_name, system_group_name)
    if system_group == None:
        print >> sys.stderr, _("Could not find system group [ %s ] within organization [ %s ]") % (system_group_name, org_name)
    return system_group
