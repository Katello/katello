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

from gettext import gettext as _
from katello.client.api.organization import OrganizationAPI
from katello.client.api.environment import EnvironmentAPI
from katello.client.api.product import ProductAPI
from katello.client.api.repo import RepoAPI
from katello.client.api.provider import ProviderAPI
from katello.client.api.template import TemplateAPI
from katello.client.api.changeset import ChangesetAPI

def get_organization(orgName):
    organization_api = OrganizationAPI()

    org = organization_api.organization(orgName)
    if org == None:
        print _("Could not find organization [ %s ]") % orgName

    return org


def get_environment(orgName, envName=None):
    environment_api = EnvironmentAPI()

    if envName == None:
        env = environment_api.locker_by_org(orgName)
        envName = env['name']
    else:
        env = environment_api.environment_by_name(orgName, envName)

    if env == None:
        print _("Could not find environment [ %s ] within organization [ %s ]") % (envName, orgName)
    return env


def get_locker(orgName):
    return get_environment(orgName, None)


def get_product(orgName, prodName):
    product_api = ProductAPI()

    prod = product_api.product_by_name(orgName, prodName)
    if prod == None:
        print _("Could not find product [ %s ] within organization [ %s ]") % (prodName, orgName)
    return prod


def get_repo(orgName, prodName, repoName, envName=None):
    repo_api = RepoAPI()

    env  = get_environment(orgName, envName)
    prod = get_product(orgName, prodName)

    if env == None:
        print _("Could not find environment [ %s ]") % envName
        return None

    if prod == None:
        print _("Could not find product [ %s ]") % prodName
        return None

    repos = repo_api.repos_by_env_product(env["id"], prod["id"])
    for repo in repos:
        if repo["name"] == repoName:
            return repo

    print _("Could not find repository [ %s ] within organization [ %s ], product [ %s ] and environemnt [ %s ]") % (repoName, orgName, prodName, env["name"])
    return None


def get_provider(orgName, provName):
    provider_api = ProviderAPI()

    prov = provider_api.provider_by_name(orgName, provName)
    if prov == None:
        print _("Could not find provider [ %s ] within organization [ %s ]") % (provName, orgName)
    return prov


def get_template(orgName, envName, tplName):
    template_api = TemplateAPI()

    env = get_environment(orgName, envName)
    if env == None:
        return None

    tpl = template_api.template_by_name(env["id"], tplName)
    if tpl == None:
        print _("Could not find template [ %s ] within environment [ %s ]") % (tplName, env["name"])
    return tpl


def get_changeset(orgName, envName, csName):
    changeset_api = ChangesetAPI()

    env = get_environment(orgName, envName)
    if env == None:
        return None

    cset = changeset_api.changeset_by_name(orgName, env["id"], csName)
    if cset == None:
        print _("Could not find changeset [ %s ] within environment [ %s ]") % (csName, env["name"])
    return cset
