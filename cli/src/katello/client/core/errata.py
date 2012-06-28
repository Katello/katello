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

import os
from gettext import gettext as _

from katello.client.api.errata import ErrataAPI
from katello.client.api.system import SystemAPI
from katello.client.api.system_group import SystemGroupAPI
from katello.client.config import Config
from katello.client.core.base import BaseAction, Command
from katello.client.api.utils import get_repo, get_environment, get_product, get_system_group
from katello.client.utils.encoding import u_str
from katello.client.utils import printer

Config()

# base package action --------------------------------------------------------

class ErrataAction(BaseAction):

    def __init__(self):
        super(ErrataAction, self).__init__()
        self.api = ErrataAPI()


# package actions ------------------------------------------------------------

class List(ErrataAction):

    description = _('list all errata for a repo')

    def setup_parser(self, parser):
        parser.add_option('--repo_id', dest='repo_id',
                      help=_("repository id"))
        parser.add_option('--repo', dest='repo',
                      help=_("repository name"))
        parser.add_option('--org', dest='org',
                      help=_("organization name eg: foo.example.com"))
        parser.add_option('--environment', dest='env',
                      help=_("environment name eg: production (default: Library)"))
        parser.add_option('--product', dest='product',
                      help=_("product name eg: fedora-14"))


        parser.add_option('--type', dest='type',
                      help=_("filter errata by type eg: enhancements"))
        parser.add_option('--severity', dest='severity',
                      help=_("filter errata by severity"))

    def check_options(self, validator):
        if not validator.exists('repo_id'):
            validator.require('org')
        if validator.exists('repo'):
            validator.require(('org', 'product'))

    def run(self):
        repo_id   = self.get_option('repo_id')
        repo_name = self.get_option('repo')
        org_name  = self.get_option('org')
        env_name  = self.get_option('env')
        env_id, prod_id = None, None
        prod_name = self.get_option('product')

        self.printer.add_column('id')
        self.printer.add_column('title')
        self.printer.add_column('type')

        if not repo_id:
            if repo_name:
                repo = get_repo(org_name, prod_name, repo_name, env_name)
                repo_id = repo["id"]
            else:
                env = get_environment(org_name, env_name)
                env_id = env["id"]
                if prod_name:
                    product = get_product(org_name, prod_name)
                    prod_id = product["id"]


        errata = self.api.errata_filter(repo_id=repo_id, environment_id=env_id, type=self.get_option('type'), severity=self.get_option('severity'),prod_id=prod_id)

        self.printer.set_header(_("Errata List"))
        self.printer.print_items(errata)
        return os.EX_OK

class SystemErrata(ErrataAction):
    description = _("list errata for a system")

    def setup_parser(self, parser):
        parser.add_option('--org', dest='org',
                       help=_("organization name (required)"))
        parser.add_option('--name', dest='name',
                                   help=_("system name (required)"))

    def check_options(self, validator):
        validator.require(('org', 'name'))

    def run(self):
        systemApi = SystemAPI()

        org_name = self.get_option('org')
        sys_name = self.get_option('name')

        systems = systemApi.systems_by_org(org_name, {'name': sys_name})

        errata = systemApi.errata(systems[0]["uuid"])

        self.printer.add_column('id')
        self.printer.add_column('title')
        self.printer.add_column('type')

        self.printer.set_header(_("Errata for system %s in organization %s") % (sys_name, org_name))
        self.printer.print_items(errata)

        return os.EX_OK

class SystemGroupErrata(ErrataAction):
    description = _("list errata for a system group")

    def setup_parser(self, parser):
        parser.add_option('--org', dest='org', help=_("organization name (required)"))
        parser.add_option('--name', dest='name', help=_("system group name (required)"))
        parser.add_option('--type', dest='type', help=_("filter errata by type eg: bug, enhancement or security"))

    def check_options(self, validator):
        validator.require(('org', 'name'))

    def run(self):
        systemGroupApi = SystemGroupAPI()

        org_name = self.get_option('org')
        group_name = self.get_option('name')
        type = self.get_option('type')

        system_group = get_system_group(org_name, group_name)
        system_group_id = system_group['id']

        errata = systemGroupApi.errata(org_name, system_group_id, type=type)

        self.printer.add_column('id')
        self.printer.add_column('title')
        self.printer.add_column('type')
        self.printer.add_column('systems', _('# Systems'), formatter=len)
        self.printer.add_column('systems', multiline=True, show_with=printer.VerboseStrategy)

        self.printer.set_header(_("Errata for system group %s in organization %s") % (group_name, org_name))
        self.printer.print_items(errata)

        return os.EX_OK


class Info(ErrataAction):

    description = _('information about an errata')

    def setup_parser(self, parser):
        parser.add_option('--id', dest='id',
                               help=_("errata id, string value (required)"))
        parser.add_option('--repo_id', dest='repo_id',
                      help=_("repository id"))
        parser.add_option('--repo', dest='repo',
                      help=_("repository name"))
        parser.add_option('--org', dest='org',
                      help=_("organization name eg: foo.example.com"))
        parser.add_option('--environment', dest='env',
                      help=_("environment name eg: production (default: Library)"))
        parser.add_option('--product', dest='product',
                      help=_("product name eg: fedora-14"))

    def check_options(self, validator):
        validator.require('id')
        if not validator.exists('repo_id'):
            validator.require(('repo', 'org', 'product'))

    def run(self):
        errId    = self.get_option('id')
        repoId   = self.get_option('repo_id')
        repoName = self.get_option('repo')
        orgName  = self.get_option('org')
        envName  = self.get_option('env')
        prodName = self.get_option('product')

        if not repoId:
            repo = get_repo(orgName, prodName, repoName, envName)
            repoId = repo["id"]

        pack = self.api.errata(errId, repoId)

        pack['affected_packages'] = [u_str(pinfo['filename'])
                         for pkg in pack['pkglist']
                         for pinfo in pkg['packages']]

        self.printer.add_column('id')
        self.printer.add_column('title')
        self.printer.add_column('description', multiline=True)
        self.printer.add_column('type')
        self.printer.add_column('issued')
        self.printer.add_column('updated')
        self.printer.add_column('version')
        self.printer.add_column('release')
        self.printer.add_column('status')
        self.printer.add_column('reboot_suggested')
        self.printer.add_column('affected_packages', multiline=True)

        self.printer.set_header(_("Errata Information"))
        self.printer.print_item(pack)
        return os.EX_OK


# package command ------------------------------------------------------------

class Errata(Command):

    description = _('errata specific actions in the katello server')
