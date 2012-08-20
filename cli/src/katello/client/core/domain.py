#
# Katello Domains actions
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

import os
from gettext import gettext as _

from katello.client.api.domain import DomainAPI
from katello.client.config import Config
from katello.client.core.base import BaseAction, Command
from katello.client.core.utils import system_exit, unnest_one

Config()

# base domain action --------------------------------------------------------

class DomainAction(BaseAction):

    def __init__(self):
        super(DomainAction, self).__init__()
        self.api = DomainAPI()

# domain actions ------------------------------------------------------------

class List(DomainAction):

    description = _('list domains')

    def setup_parser(self, parser):
        parser.add_option('--search', dest='search', help=_("Filter results"))
        parser.add_option('--order', dest='order', help=_("Sort results"))

    def check_options(self, validator):
        pass

    def run(self):
        data = self.get_option_dict('search', 'order')
        domains = unnest_one(self.api.list(data))

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('fullname')
        self.printer.add_column('dns_id')

        self.printer.set_header(_("Domains"))
        self.printer.print_items(domains)

class Show(DomainAction):

    description = _('show domain')

    def setup_parser(self, parser):
        parser.add_option('--id', dest='id', help=_("domain id or name"))

    def check_options(self, validator):
        validator.require('id')

    def run(self):
        id = self.get_option('id')
        domain = unnest_one(self.api.show(id))

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('fullname')
        self.printer.add_column('dns_id')

        self.printer.set_header(_("Domain"))
        self.printer.print_item(domain)


# TODO: domain_parameters_attributes (after domains API merge to foreman develop)
class Create(DomainAction):

    description = _('create domain')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name', help=_("The full DNS Domain name"))
        parser.add_option('--fullname', dest='fullname', help=_("Full name describing the domain"))
        parser.add_option('--dns_id', dest='dns_id', help=_("DNS Proxy to use within this domain"))
        # parser.add_option('--domain_parameters_attributes', dest='domain_parameters_attributes', help=_("Array of parameters (name, value)"))

    def check_options(self, validator):
        validator.require('name')

    def run(self):
        data = self.get_option_dict('name','fullname','dns_id') #'domain_parameters_attributes'
        domain = self.api.create(data)

        if type(domain)==type(dict()) and 'domain' in domain:
            system_exit(os.EX_OK, _('Successfuly created Domain [ %s ]') % data['name'])
        else:
            system_exit(os.EX_DATAERR, _("Could not update Domain [ %s ]") % data['name'])


class Update(DomainAction):

    description = _('update domain')

    def setup_parser(self, parser):
        parser.add_option('--id', dest='id', help=_("Domain id"))
        parser.add_option('--name', dest='name', help=_("The full DNS Domain name(required)"))
        parser.add_option('--fullname', dest='fullname', help=_("Full name describing the domain"))
        parser.add_option('--dns_id', dest='dns_id', help=_("DNS Proxy to use within this domain"))
        # parser.add_option('--domain_parameters_attributes', dest='domain_parameters_attributes', help=_("Array of parameters (name, value)"))

    def check_options(self, validator):
        validator.require('name')

    def run(self):
        domain_id = self.get_option('id')
        data = self.get_option_dict('name','fullname','dns_id') #,'domain_parameters_attributes'

        domain = self.api.update(domain_id, data)

        if type(domain)==type(dict()) and 'domain' in domain:
            system_exit(os.EX_OK, _('Successfuly updated Domain [ %s ]') % domain_id)
        else:
            system_exit(os.EX_DATAERR, _("Could not create Domain [ %s ]") % domain_id)


class Destroy(DomainAction):

    description = _('destroy domain')

    def setup_parser(self, parser):
        parser.add_option('--id', dest='id', help=_("domain id or name"))

    def check_options(self, validator):
        validator.require('id')

    def run(self):
        domain_id = self.get_option('id')
        status = self.api.destroy(domain_id)
        print status
        print _('Successfuly deleted Domain [ %s ]') % domain_id


# domain command ------------------------------------------------------------

class Domain(Command):

    description = _('domain specific actions in the katello server')