# -*- coding: utf-8 -*-
#
# Katello Organization actions
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


from katello.client.api.smart_proxy import SmartProxyAPI
from katello.client.core.base import BaseAction, Command
from katello.client.lib.utils.data import unnest_one
from katello.client.lib.ui.printer import batch_add_columns

# base smart proxy action --------------------------------------------------------

class SmartProxyAction(BaseAction):

    def __init__(self):
        super(SmartProxyAction, self).__init__()
        self.api = SmartProxyAPI()

# smart proxy actions ------------------------------------------------------------

class List(SmartProxyAction):

    description = _('list smart proxy')

    def setup_parser(self, parser):
        pass

    def check_options(self, validator):
        pass

    def run(self):
        proxies = unnest_one(self.api.list())
        batch_add_columns(self.printer, {'name': _("Name")}, {'url': _("URL")})

        self.printer.set_header(_("Smart Proxies"))
        self.printer.print_items(proxies)


class Info(SmartProxyAction):

    description = _('show smart proxy')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name', help=_("domain name (required)"))

    def check_options(self, validator):
        validator.require('name')

    def run(self):
        proxy = self.api.show(self.get_option('name'))
        proxy = unnest_one(proxy)
        batch_add_columns(self.printer, {'name': _("Name")}, {'url': _("URL")})
        self.printer.add_column('features', _("Features"), multiline=True)

        self.printer.set_header(_("Smart Proxy"))
        self.printer.print_item(proxy)


class Create(SmartProxyAction):

    description = _('create a smart proxy')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name', help=_("smart proxy name (required)"))
        parser.add_option('--url', dest='url',
            help=_("smart proxy URL starting with 'http://' or 'https://' (required)"))

    def check_options(self, validator):
        validator.require(('name', 'url'))

    def run(self):
        smartproxy = self.api.create(self.get_option_dict('name', 'url'))
        print _('Smart Proxy [ %s ] created') % unnest_one(smartproxy)['name']


class Update(SmartProxyAction):

    description = _('update smart proxy')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='old_name', help=_("smart proxy name (required)"))
        parser.add_option('--new_name', dest='name', help=_("new smart proxy name"))
        parser.add_option('--url', dest='url', help=_("smart proxy URL starting with 'http://' or 'https://'"))

    def check_options(self, validator):
        validator.require('old_name')
        validator.require_at_least_one_of(('name', 'url'))

    def run(self):
        self.api.update(self.get_option('old_name'), self.get_option_dict('name', 'url'))
        print _('Smart Proxy [ %s ] updated') % self.get_option('old_name')

class Delete(SmartProxyAction):

    description = _('destroy smart proxy')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name', help=_("smart proxy name (required)"))

    def check_options(self, validator):
        validator.require('name')

    def run(self):
        self.api.destroy(self.get_option('name'))
        print _('Smart Proxy [ %s ] deleted') % self.get_option('name')


# smart proxy command ------------------------------------------------------------

class SmartProxy(Command):

    description = _('smart proxy specific actions in the katello server')
