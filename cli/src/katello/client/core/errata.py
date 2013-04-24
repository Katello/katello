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

import os

from katello.client.api.errata import ErrataAPI
from katello.client.api.system import SystemAPI
from katello.client.api.system_group import SystemGroupAPI
from katello.client.cli.base import opt_parser_add_product, opt_parser_add_org, \
        opt_parser_add_environment, opt_parser_add_content_view
from katello.client.core.base import BaseAction, Command
from katello.client.api.utils import get_repo, get_environment, get_product, \
    get_system_group, get_system
from katello.client.lib.utils.encoding import u_str
from katello.client.lib.ui import printer
from katello.client.lib.ui.printer import batch_add_columns


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
                      help=_("repository ID"))
        parser.add_option('--repo', dest='repo',
                      help=_("repository name"))
        opt_parser_add_org(parser, required=1)
        opt_parser_add_environment(parser, default=_("Library"))
        opt_parser_add_product(parser)
        opt_parser_add_content_view(parser)

        parser.add_option('--type', dest='type',
                      help=_("filter errata by type eg: enhancements"))
        parser.add_option('--severity', dest='severity',
                      help=_("filter errata by severity"))

    def check_options(self, validator):
        if not validator.exists('repo_id'):
            validator.require('org')
        if validator.exists('repo'):
            validator.require('org')
            validator.require_at_least_one_of(('product', 'product_label', 'product_id'))
            validator.mutually_exclude('product', 'product_label', 'product_id')
            validator.mutually_exclude('view_name', 'view_label', 'view_id')
        if validator.exists('view_name') or validator.exists('view_label') or validator.exists('view_id'):
            # TODO: support the case where no repo info is supplied.
            validator.require_at_least_one_of('repo', 'repo_id')

    def run(self):
        repo_id   = self.get_option('repo_id')
        repo_name = self.get_option('repo')
        org_name  = self.get_option('org')
        env_name  = self.get_option('environment')
        env_id, prod_id = None, None
        prod_name = self.get_option('product')
        prod_label = self.get_option('product_label')
        prod_id = self.get_option('product_id')
        viewName = self.get_option('view_name')
        viewLabel = self.get_option('view_label')
        viewId = self.get_option('view_id')

        self.printer.add_column('id', _("ID"))
        self.printer.add_column('title', _("Title"))
        self.printer.add_column('type', _("Type"))

        if not repo_id:
            if repo_name:
                repo = get_repo(org_name, repo_name, prod_name, prod_label, prod_id, env_name, False,
                                viewName, viewLabel, viewId)
                repo_id = repo["id"]
            else:
                env = get_environment(org_name, env_name)
                env_id = env["id"]
                if prod_name:
                    product = get_product(org_name, prod_name, prod_label, prod_id)
                    prod_id = product["id"]


        errata = self.api.errata_filter(repo_id=repo_id, environment_id=env_id, type_in=self.get_option('type'),
            severity=self.get_option('severity'), prod_id=prod_id)

        self.printer.set_header(_("Errata List"))
        self.printer.print_items(errata)
        return os.EX_OK

class SystemErrata(ErrataAction):
    description = _("list errata for a system")

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)
        parser.add_option('--name', dest='name',
                                   help=_("system name (required)"))

    def check_options(self, validator):
        validator.require(('org', 'name'))

    def run(self):
        systemApi = SystemAPI()

        org_name = self.get_option('org')
        sys_name = self.get_option('name')

        system = get_system(org_name, sys_name)
        errata = systemApi.errata(system["uuid"])

        batch_add_columns(self.printer, {'id': _("ID")}, {'title': _("Title")}, {'type': _("Type")})
        self.printer.set_header(_("Errata for system %(sys_name)s in organization %(org_name)s")
            % {'sys_name':sys_name, 'org_name':org_name})
        self.printer.print_items(errata)

        return os.EX_OK

class SystemGroupErrata(ErrataAction):
    description = _("list errata for a system group")

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)
        parser.add_option('--name', dest='name', help=_("system group name (required)"))
        parser.add_option('--type', dest='type', help=_("filter errata by type eg: bug, enhancement or security"))

    def check_options(self, validator):
        validator.require(('org', 'name'))

    def run(self):
        systemGroupApi = SystemGroupAPI()

        org_name = self.get_option('org')
        group_name = self.get_option('name')
        type_in = self.get_option('type')

        system_group = get_system_group(org_name, group_name)
        system_group_id = system_group['id']

        errata = systemGroupApi.errata(org_name, system_group_id, type_in=type_in)

        batch_add_columns(self.printer, {'id': _("ID")}, {'title': _("Title")}, {'type': _("Type")})
        self.printer.add_column('systems', _('# Systems'), formatter=len)
        self.printer.add_column('systems', _("Systems"), multiline=True, show_with=printer.VerboseStrategy)

        self.printer.set_header(_("Errata for system group %(org_name)s in organization %(org_name)s")
            % {'group_name':group_name, 'org_name':org_name})
        self.printer.print_items(errata)

        return os.EX_OK


class Info(ErrataAction):

    description = _('information about an errata')

    def setup_parser(self, parser):
        parser.add_option('--id', dest='id',
                               help=_("errata ID, string value (required)"))
        parser.add_option('--repo_id', dest='repo_id',
                      help=_("repository ID"))
        parser.add_option('--repo', dest='repo',
                      help=_("repository name (required)"))
        opt_parser_add_org(parser, required=1)
        opt_parser_add_environment(parser, default=_("Library"))
        opt_parser_add_product(parser)

    def check_options(self, validator):
        validator.require('id')
        if not validator.exists('repo_id'):
            validator.require(('repo', 'org'))
            validator.require_at_least_one_of(('product', 'product_label', 'product_id'))
            validator.mutually_exclude('product', 'product_label', 'product_id')

    def run(self):
        errId    = self.get_option('id')
        repoId   = self.get_option('repo_id')
        repoName = self.get_option('repo')
        orgName  = self.get_option('org')
        envName  = self.get_option('environment')
        prodName = self.get_option('product')
        prodLabel = self.get_option('product_label')
        prodId   = self.get_option('product_id')

        if not repoId:
            repo = get_repo(orgName, repoName, prodName, prodLabel, prodId, envName)
            repoId = repo["id"]

        pack = self.api.errata(errId, repoId)

        pack['affected_packages'] = [u_str(pinfo['filename'])
                         for pkg in pack['pkglist']
                         for pinfo in pkg['packages']]

        batch_add_columns(self.printer, {'id': _("ID")}, {'title': _("Title")})
        self.printer.add_column('description', _("Description"), multiline=True)
        batch_add_columns(self.printer, {'type': _("Type")}, {'issued': _("Issued")}, \
            {'updated': _("Updated")}, {'version': _("Version")}, {'release': _("Release")}, \
            {'status': _("Status")}, {'reboot_suggested': _("Reboot Suggested")})
        self.printer.add_column('affected_packages', _("Affected Packages"), multiline=True)

        self.printer.set_header(_("Errata Information"))
        self.printer.print_item(pack)
        return os.EX_OK


# package command ------------------------------------------------------------

class Errata(Command):

    description = _('errata specific actions in the katello server')
