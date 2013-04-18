#
# Katello Repos actions
# Copyright 2013 Red Hat, Inc.
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


from katello.client.api.organization import OrganizationAPI
from katello.client.api.environment import EnvironmentAPI
from katello.client.api.product import ProductAPI
from katello.client.api.repo import RepoAPI
from katello.client.api.provider import ProviderAPI
from katello.client.api.changeset import ChangesetAPI
from katello.client.api.user import UserAPI
from katello.client.api.user_role import UserRoleAPI
from katello.client.api.sync_plan import SyncPlanAPI
from katello.client.api.permission import PermissionAPI
from katello.client.api.system_group import SystemGroupAPI
from katello.client.api.system import SystemAPI
from katello.client.api.distributor import DistributorAPI
from katello.client.api.content_view import ContentViewAPI
from katello.client.api.content_view_definition import ContentViewDefinitionAPI
from katello.client.api.filter import FilterAPI


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
        raise ApiDataError(_("Could not find environment [ %(envName)s ] within organization [ %(orgName)s ]") %
            {'envName':envName, 'orgName':orgName})
    return env


def get_library(orgName):
    return get_environment(orgName, None)


def get_product(orgName, prodName=None, prodLabel=None, prodId=None):
    """
    Retrieve product by name, label or id.
    """
    product_api = ProductAPI()

    products = product_api.product_by_name_or_label_or_id(orgName, prodName, prodLabel, prodId)

    if len(products) > 1:
        raise ApiDataError(_("More than 1 product found with the name or label provided, "\
                             "recommend using product id.  The product id may be retrieved "\
                             "using the 'product list' command."))
    elif len(products) == 0:
        raise ApiDataError(_("Could not find product [ %(prodName)s ] within organization [ %(orgName)s ]") %
            {'prodName':prodName or prodLabel or prodId, 'orgName':orgName})

    return products[0]


def get_content_view(org_name, view_label=None, view_name=None, view_id=None):
    cv_api = ContentViewAPI()

    views = cv_api.views_by_label_name_or_id(org_name, view_label,
            view_name, view_id)

    if len(views) > 1:
        raise ApiDataError(_("More than 1 content view with name provided, " \
                             "recommend using label or id. These may be " \
                             "retrieved using 'content view list'."))

    elif len(views) == 0:
        raise ApiDataError(_("Could not find content view [ %s ] within " \
            "organization [ %s ]") %
            ((view_label or view_name or view_id), org_name))
    return views[0]


def get_cv_definition(org_name, def_label=None, def_name=None, def_id=None):
    cvd_api = ContentViewDefinitionAPI()

    cvds = cvd_api.cvd_by_label_or_name_or_id(org_name, def_label, def_name,
            def_id)

    if len(cvds) > 1:
        raise ApiDataError(_("More than 1 definition found with name, " \
                "recommend using label or id. These may be retrieved using " \
                "the 'content definition list' command"))
    elif len(cvds) < 1:
        raise ApiDataError(_("Could not find content view definition [ %(a)s ]" \
                " within organization [ %(b)s ]") %
                ({"a": (def_label or def_id or def_name), "b": org_name}))

    return cvds[0]


def get_filter(org_name, def_id, filter_name):
    filter_api = FilterAPI()
    filters = filter_api.filters_by_cvd_and_org(def_id, org_name)

    filters = [f for f in filters if f["name"] == filter_name]

    if len(filters) < 1:
        raise ApiDataError(_("Could not find filter [ %s ].") % filter_name)
    else:
        # there can only be one filter matching name in a def
        return filters[0]


def get_repo(orgName, repoName, prodName=None, prodLabel=None, prodId=None, envName=None, includeDisabled=False,
             viewName=None, viewLabel=None, viewId=None):
    repo_api = RepoAPI()

    env  = get_environment(orgName, envName)
    prod = get_product(orgName, prodName, prodLabel, prodId)

    view = None
    viewId = None
    if viewName or viewLabel or viewId:
        view = get_content_view(orgName, viewLabel, viewName, viewId)
        viewId = view["id"]

    repos = repo_api.repos_by_env_product(env["id"], prod["id"], repoName, includeDisabled, viewId)
    if len(repos) > 0:
        #repo by id call provides more information
        return repo_api.repo(repos[0]["id"])

    if view:
        error = _("Could not find repository [ %(repoName)s ] within organization [ %(orgName)s ], " \
            "product [ %(prodName)s ], content view [ %(viewName)s ], and environment "\
            "[ %(env_name)s ]") % {'repoName':repoName, 'orgName':orgName, 'prodName':prod["name"],
                                   'viewName':view["name"], 'env_name':env["name"]}
    else:
        error = _("Could not find repository [ %(repoName)s ] within organization [ %(orgName)s ], " \
            "product [ %(prodName)s ] and environment [ %(env_name)s ]") % \
            {'repoName':repoName, 'orgName':orgName, 'prodName':prod["name"], 'env_name':env["name"]}

    raise ApiDataError(error)

def get_provider(orgName, provName):
    provider_api = ProviderAPI()

    prov = provider_api.provider_by_name(orgName, provName)
    if prov == None:
        raise ApiDataError(_("Could not find provider [ %(provName)s ] within organization [ %(orgName)s ]") %
            {'provName':provName, 'orgName':orgName})
    return prov


def get_changeset(orgName, envName, csName):
    changeset_api = ChangesetAPI()

    env = get_environment(orgName, envName)
    cset = changeset_api.changeset_by_name(orgName, env["id"], csName)
    if cset == None:
        raise ApiDataError(_("Could not find changeset [ %(csName)s ] within environment [ %(env_name)s ]") %
            {'csName':csName, 'env_name':env["name"]})
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
        raise ApiDataError(_("Cannot find permission [ %(role_name)s ] for user role [ %(permission_name)s ]") %
            {'role_name':role_name, 'permission_name':permission_name})
    return perm

def get_system_group(org_name, system_group_name):
    system_group_api = SystemGroupAPI()

    system_group = system_group_api.system_group_by_name(org_name, system_group_name)
    if system_group == None:
        raise ApiDataError(_("Could not find system group [ %(system_group_name)s ] " \
            "within organization [ %(org_name)s ]") \
            % {'system_group_name':system_group_name, 'org_name':org_name})
    return system_group

def get_system(org_name, sys_name, env_name=None, sys_uuid=None):
    system_api = SystemAPI()
    if sys_uuid:
        systems = system_api.systems_by_org(org_name, {'uuid': sys_uuid})
        if systems is None:
            raise ApiDataError(_("Could not find System [ %(sys_name)s ] in Org [ %(org_name)s ]") \
                % {'sys_name':sys_name, 'org_name':org_name})
        elif len(systems) != 1:
            raise ApiDataError(_("Found ambiguous Systems [ %(sys_uuid)s ] in Org [ %(org_name)s ]") \
                % {'sys_uuid':sys_uuid, 'org_name':org_name})
    elif env_name is None:
        systems = system_api.systems_by_org(org_name, {'name': sys_name})
        if systems is None or len(systems) == 0:
            raise ApiDataError(_("Could not find System [ %(sys_name)s ] in Org [ %(org_name)s ]") \
                % {'sys_name':sys_name, 'org_name':org_name})
        elif len(systems) != 1:
            raise ApiDataError( _("Found ambiguous Systems [ %(sys_name)s ] " \
                "in Environment [ %(env_name)s ] in Org [ %(org_name)s ], "\
                "use --uuid to specify the system") % {'sys_name':sys_name, 'env_name':env_name, 'org_name':org_name})
    else:
        environment = get_environment(org_name, env_name)
        systems = system_api.systems_by_env(environment["id"], {'name': sys_name})
        if systems is None:
            raise ApiDataError(_("Could not find System [ %(sys_name)s ] " \
                "in Environment [ %(env_name)s ] in Org [ %(org_name)s ]") \
                % {'sys_name':sys_name, 'env_name':env_name, 'org_name':org_name})
        elif len(systems) != 1:
            raise ApiDataError(_("Found ambiguous Systems [ %(sys_name)s ] in Org [ %(org_name)s ], "\
                "you have to specify the environment") % {'sys_name':sys_name, 'org_name':org_name})

    return system_api.system(systems[0]['uuid'])

def get_distributor(org_name, dist_name, env_name=None, dist_uuid=None):
    distributor_api = DistributorAPI()
    if dist_uuid:
        distributors = distributor_api.distributors_by_org(org_name, {'uuid': dist_uuid})
        if distributors is None:
            raise ApiDataError(_("Could not find Distributor [ %(dist_name)s ] in Org [ %(org_name)s ]") \
                % {'dist_name':dist_name, 'org_name':org_name})
        elif len(distributors) != 1:
            raise ApiDataError(_("Found ambiguous Distributors [ %(dist_uuid)s ] in Org [ %(org_name)s ]") \
                % {'dist_uuid':dist_uuid, 'org_name':org_name})
    elif env_name is None:
        distributors = distributor_api.distributors_by_org(org_name, {'name': dist_name})
        if distributors is None or len(distributors) == 0:
            raise ApiDataError(_("Could not find Distributor [ %(dist_name)s ] in Org [ %(org_name)s ]") \
                % {'dist_name':dist_name, 'org_name':org_name})
        elif len(distributors) != 1:
            raise ApiDataError( _("Found ambiguous Distributors [ %(dist_name)s ] " \
                "in Environment [ %(env_name)s ] in Org [ %(org_name)s ], "\
                "use --uuid to specify the distributor") % {'dist_name':dist_name, 'env_name':env_name,
                                                            'org_name':org_name})
    else:
        environment = get_environment(org_name, env_name)
        distributors = distributor_api.distributors_by_env(environment["id"], {'name': dist_name})
        if distributors is None:
            raise ApiDataError(_("Could not find Distributor [ %(dist_name)s ] " \
                "in Environment [ %(env_name)s ] in Org [ %(org_name)s ]") \
                % {'dist_name':dist_name, 'env_name':env_name, 'org_name':org_name})
        elif len(distributors) != 1:
            raise ApiDataError(_("Found ambiguous Distributors [ %(dist_name)s ] in Org [ %(org_name)s ], "\
                "you have to specify the environment") % {'dist_name':dist_name, 'org_name':org_name})

    return distributor_api.distributor(distributors[0]['uuid'])
