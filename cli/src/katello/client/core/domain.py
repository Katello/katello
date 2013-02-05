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

from katello.client.api.domain import DomainAPI
from katello.client.core.base import BaseAction, Command
from katello.client.lib.utils.data import test_foreman_record, unnest_one
from katello.client.lib.ui.printer import batch_add_columns


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
        domains = self.api.list(data)
        if domains:
            domains = unnest_one(domains)

        batch_add_columns(self.printer, {'id': _("ID")}, {'name': _("Name")}, \
            {'fullname': _("Full Name")}, {'dns_id': _("DNS ID")})

        self.printer.set_header(_("Domains"))
        self.printer.print_items(domains)

class Info(DomainAction):

    description = _('show information about a domain')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='id', help=_("domain id or name (required)"))

    def check_options(self, validator):
        validator.require('id')

    def run(self):
        domain_id = self.get_option('id')
        domain = unnest_one(self.api.show(domain_id))

        batch_add_columns(self.printer, {'id': _("ID")}, {'name': _("Name")}, \
            {'fullname': _("Full Name")}, {'dns_id': _("DNS ID")})

        self.printer.set_header(_("Domain"))
        self.printer.print_item(domain)


# TODO: domain_parameters_attributes (after domains API merge to foreman develop)
class Create(DomainAction):

    description = _('create domain')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name', help=_("The full DNS Domain name (required)"))
        parser.add_option('--fullname', dest='fullname', help=_("Full name describing the domain"))
        parser.add_option('--dns_id', dest='dns_id', help=_("DNS Proxy to use within this domain"))

    def check_options(self, validator):
        validator.require('name')

    def run(self):
        data = self.get_option_dict('name', 'fullname', 'dns_id')
        domain = self.api.create(data)

        test_foreman_record(domain, 'domain',
            _('Successfuly created Domain [ %s ]') % data['name'],
            _("Could not update Domain [ %s ]") % data['name']
        )


class Update(DomainAction):

    description = _('update domain')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='id', help=_("Domain id (required)"))
        parser.add_option('--new_name', dest='name', help=_("The full DNS Domain name"))
        parser.add_option('--fullname', dest='fullname', help=_("Full name describing the domain"))
        parser.add_option('--dns_id', dest='dns_id', help=_("DNS Proxy to use within this domain"))

    def check_options(self, validator):
        validator.require('id')

    def run(self):
        domain_id = self.get_option('id')
        data = self.get_option_dict('name', 'fullname', 'dns_id')

        domain = self.api.update(domain_id, data)

        test_foreman_record(domain, 'domain',
            _('Successfuly updated Domain [ %s ]') % domain_id,
            _("Could not create Domain [ %s ]") % domain_id
        )


class Delete(DomainAction):

    description = _('delete domain')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='id', help=_("domain id or name (required)"))

    def check_options(self, validator):
        validator.require('id')

    def run(self):
        domain_id = self.get_option('id')
        self.api.destroy(domain_id)
        print _('Successfuly deleted Domain [ %s ]') % domain_id


# domain command ------------------------------------------------------------

class Domain(Command):

    description = _('domain specific actions in the katello server')
