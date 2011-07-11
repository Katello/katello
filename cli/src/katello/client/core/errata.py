#!/usr/bin/python
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
import urlparse
from gettext import gettext as _
from pprint import pprint

from katello.client.api.errata import ErrataAPI
from katello.client.config import Config
from katello.client.core.base import Action, Command
from katello.client.api.utils import get_repo

_cfg = Config()

# base package action --------------------------------------------------------

class ErrataAction(Action):

    def __init__(self):
        super(ErrataAction, self).__init__()
        self.api = ErrataAPI()


# package actions ------------------------------------------------------------

class List(ErrataAction):

    description = _('list all errata for a repo')

    def setup_parser(self):
        self.parser.add_option('--repo_id', dest='repo_id',
                      help=_("repository id"))
        self.parser.add_option('--repo', dest='repo',
                      help=_("repository name"))
        self.parser.add_option('--org', dest='org',
                      help=_("organization name eg: foo.example.com"))
        self.parser.add_option('--environment', dest='env',
                      help=_("environment name eg: production (default: locker)"))
        self.parser.add_option('--product', dest='product',
                      help=_("product name eg: fedora-14"))

    def check_options(self):
        if not self.has_option('repo_id'):
            self.require_option('repo')
            self.require_option('org')
            self.require_option('product')

    def run(self):
        repoId   = self.get_option('repo_id')
        repoName = self.get_option('repo')
        orgName  = self.get_option('org')
        envName  = self.get_option('env')
        prodName = self.get_option('product')

        self.printer.addColumn('id')
        self.printer.addColumn('title')
        self.printer.addColumn('type')

        if not repoId:
            repo = get_repo(orgName, prodName, repoName, envName)
            if repo == None:
                return os.EX_OK
            repoId = repo["id"]

        errata = self.api.errata_by_repo(repoId)

        self.printer.setHeader(_("Errata List"))
        self.printer.printItems(errata)
        return os.EX_OK


class Info(ErrataAction):

    description = _('information about an errata')

    def setup_parser(self):
        self.parser.add_option('--id', dest='id',
                               help=_("errata id, string value (required)"))

    def check_options(self):
        self.require_option('id')

    def run(self):
        errId = self.get_option('id')
        pack = self.api.errata(errId)

        pack['affected_packages'] = [str(pinfo['filename'])
                         for pkg in pack['pkglist']
                         for pinfo in pkg['packages']]

        self.printer.addColumn('id')
        self.printer.addColumn('title')
        self.printer.addColumn('description', multiline=True)
        self.printer.addColumn('type')
        self.printer.addColumn('issued')
        self.printer.addColumn('updated')
        self.printer.addColumn('version')
        self.printer.addColumn('release')
        self.printer.addColumn('status')
        self.printer.addColumn('reboot_suggested')
        self.printer.addColumn('affected_packages', multiline=True)

        self.printer.setHeader(_("Errata Information"))
        self.printer.printItem(pack)
        return os.EX_OK


# package command ------------------------------------------------------------

class Errata(Command):

    description = _('errata specific actions in the katello server')
