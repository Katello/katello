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


from katello.client.api.subnet import SubnetAPI
from katello.client.core.base import BaseAction, Command
from katello.client.lib.utils.data import unnest_one
from katello.client.lib.ui.printer import batch_add_columns


# base subnet action --------------------------------------------------------

class SubnetAction(BaseAction):

    def __init__(self):
        super(SubnetAction, self).__init__()
        self.api = SubnetAPI()

    @classmethod
    def format_smart_proxy(cls, proxy):
        if proxy is not None:
            return proxy.get('name', None)
        else:
            return None

# subnet actions ------------------------------------------------------------

class Update(SubnetAction):

    @property
    def description(self):
        if self._create:
            return _('create a subnet')
        else:
            return _('update a subnet')


    def __init__(self, create=False):
        self._create = create
        super(Update, self).__init__()

    def setup_parser(self, parser):
        if self._create:
            parser.add_option('--name', dest='name', help=_("Subnet name (required)"))
            parser.add_option('--network', dest='network', type="ip", help=_("Subnet network (required)"))
            parser.add_option('--mask', dest='mask', type="ip", help=_("Netmask for this subnet (required)"))
        else:
            parser.add_option('--name', dest='old_name', help=_("Subnet name (required)"))
            parser.add_option('--new_name', dest='name', help=_("New subnet name"))
            parser.add_option('--network', dest='network', type="ip", help=_("Subnet network"))
            parser.add_option('--mask', dest='mask', type="ip", help=_("Netmask for this subnet"))
        parser.add_option('--gateway', dest='gateway', type="ip", help=_("Primary DNS for this subnet"))
        parser.add_option('--dns_primary', dest='dns_primary', help=_("Primary DNS for this subnet"))
        parser.add_option('--dns_secondary', dest='dns_secondary', help=_("Secondary DNS for this subnet"))
        parser.add_option('--from', dest='from', type="ip", help=_("Starting IP Address for IP auto suggestion"))
        parser.add_option('--to', dest='to', type="ip", help=_("Ending IP Address for IP auto suggestion"))
        parser.add_option('--vlanid', dest='vlanid', help=_("VLAN ID for this subnet"))
        parser.add_option('--domain_ids', dest='domain_ids', type='list',
            help=_("Domains in which this subnet is part"))
        parser.add_option('--dhcp_id', dest='dhcp_id', help=_("DHCP Proxy to use within this subnet"))
        parser.add_option('--tftp_id', dest='tftp_id', help=_("TFTP Proxy to use within this subnet"))
        parser.add_option('--dns_id', dest='dns_id', help=_("DNS Proxy to use within this subnet"))

    def check_options(self, validator):
        if self._create:
            validator.require(('name', 'network', 'mask'))
            validator.require_all_or_none(('from', 'to'))
        else:
            validator.require('old_name')

    def run(self):
        options = self.get_option_dict(
            "name", "network",
            'mask', 'gateway', 'dns_primary',
            'dns_secondary', 'from', 'to',
            'vlanid', 'domain_ids', 'dhcp_id', 'tftp_id', 'dns_id'
        )

        if self._create:
            self.api.create(options)
            print _('Subnet [ %s ] successfully created.') % self.get_option('name')
        else:
            self.api.update(self.get_option('old_name'), options)
            print _('Subnet [ %s ] successfully updated.') % self.get_option('old_name')


class List(SubnetAction):

    description = _('list subnets')

    def setup_parser(self, parser):
        pass

    def check_options(self, validator):
        pass

    def run(self):
        subnets = unnest_one(self.api.list())

        batch_add_columns(self.printer, {'name': _("Name")}, {'network': _("Network")}, \
            {'mask': _("Mask")})
        batch_add_columns(self.printer, {'dhcp': _("DHCP")}, {'tftp': _("TFTP")}, \
            {'dns': _("DNS")}, formatter=self.format_smart_proxy)

        self.printer.set_header(_("Subnets"))
        self.printer.print_items(subnets)


class Info(SubnetAction):

    description = _('show a subnet')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name', help=_("Name of a subnet"))

    def check_options(self, validator):
        validator.require("name")

    def run(self):
        subnet = unnest_one(self.api.get(self.get_option("name")))
        batch_add_columns(self.printer, {'name': _("Name")}, {'network': _("Network")}, \
            {'mask': _("Mask")}, {'gateway': _("Gateway")}, {'dns_primary': _("Primary DNS")}, \
            {'dns_secondary': _("Secondary DNS")}, {'from': _("From")}, {'to': _("To")}, \
            {'vlanid': _("VLAN ID")})
        self.printer.add_column('domain_ids', _("Domain IDs"), multiline=True)
        batch_add_columns(self.printer, {'dhcp': _("DHCP")}, {'tftp': _("TFTP")}, \
            {'dns': _("DNS")}, formatter=self.format_smart_proxy)

        self.printer.set_header(_("Subnet"))
        self.printer.print_item(subnet)


class Delete(SubnetAction):

    description = _('delete a subnet')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name', help=_("Subnet name"))

    def check_options(self, validator):
        validator.require('name')

    def run(self):
        self.api.destroy(self.get_option("name"))
        print _("Subnet [ %s ] deleted.") % self.get_option("name")

# subnet command ------------------------------------------------------------

class Subnet(Command):

    description = _('subnet specific actions in the katello server')


