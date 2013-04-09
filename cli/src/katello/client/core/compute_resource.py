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

import os

from katello.client.api.compute_resource import ComputeResourceAPI
from katello.client.core.base import BaseAction, Command
from katello.client.lib.utils.data import test_foreman_record, unnest_one
from katello.client.lib.ui.formatters import format_date
from katello.client.lib.ui.printer import batch_add_columns


# base compute resource action --------------------------------------------------------

class ComputeResourceAction(BaseAction):

    def __init__(self):
        super(ComputeResourceAction, self).__init__()
        self.api = ComputeResourceAPI()

# compute resource actions ------------------------------------------------------------

class List(ComputeResourceAction):

    description = _('list all known compute resources')

    def run(self):
        resources = self.api.index()
        resources = unnest_one(resources)

        batch_add_columns(self.printer,
            {'id': _("ID")},
            {'name': _("Name")},
            {'url': _("Url")},
            {'provider': _("Provider")}
        )

        self.printer.set_header(_("Compute Resources List"))
        self.printer.print_items(resources)
        return os.EX_OK


class Info(ComputeResourceAction):

    description = _('show details about an compute resource')

    PROVIDER_SPECIFIC_FIELDS = {
        'ovirt': (
            {'user': _('User')},
            {'uuid': _('UUID')}),
        'ec2': (
            {'user': _('User')},
            {'region': _('Region')}),
        'vmware': (
            {'user': _('User')},
            {'uuid': _('UUID')},
            {'server': _('Server')}),
        'openstack': (
            {'user': _('User')},
            {'tenant': _('Tenant')}),
        'rackspace': (
            {'user': _('User')},
            {'region': _('Region')})
    }

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name', help=_("compute resource name (required)"))

    def check_options(self, validator):
        validator.require('name')

    def run(self):
        resource = self.api.show(self.get_option('name'))
        resource = unnest_one(resource)

        batch_add_columns(self.printer,
            {'id': _("ID")},
            {'name': _("Name")},
            {'url': _("Url")},
            {'provider': _("Provider")}
        )
        self.printer.add_column('description', _('Description'), multiline=True)

        provider_fields = self.PROVIDER_SPECIFIC_FIELDS.get(resource['provider'].lower(), tuple())
        batch_add_columns(self.printer, *provider_fields)

        batch_add_columns(self.printer,
            {'created_at': _("Created At")},
            {'updated_at': _("Updated At")},
            formatter=format_date
        )

        self.printer.set_header(_("Compute Resource"))
        self.printer.print_item(resource)
        return os.EX_OK


class Create(ComputeResourceAction):

    description = _('create compute resource')

    PROVIDER_TYPES = [ 'Libvirt', 'Ovirt', 'EC2', 'Vmware', 'Openstack', 'Rackspace' ]

    PROVIDER_REQUIRED_OPTS = {
        'ovirt':     ('user', 'password', 'uuid'),
        'ec2':       ('user', 'password', 'region'),
        'vmware':    ('user', 'password', 'uuid', 'server'),
        'openstack': ('user', 'password', 'tenant'),
        'rackspace': ('user', 'password', 'region')
    }

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name', help=_("Compute resource name (required)"))
        parser.add_option('--provider', dest='provider',
            type='choice', case_sensitive=False,
            choices=self.PROVIDER_TYPES,
            help=_("Providers include Libvirt, Ovirt, EC2, Vmware, Openstack, Rackspace (required)"))
        parser.add_option('--url', dest='url', type='url', help=_("URL for Libvirt, Ovirt, and Openstack (required)"))
        parser.add_option('--description', dest='description', help=_(""))
        parser.add_option('--user', dest='user', help=_("Username for Ovirt, Vmware, Openstack. Access Key for EC2."))
        parser.add_option('--password', dest='password',
            help=_("Password for Ovirt, Vmware, Openstack. Secret key for EC2"))
        parser.add_option('--uuid', dest='uuid', help=_("for Ovirt, Vmware Datacenter"))
        parser.add_option('--region', dest='region', help=_("for EC2 only"))
        parser.add_option('--tenant', dest='tenant', help=_("for Openstack only"))
        parser.add_option('--server', dest='server', help=_("for Vmware"))

    def check_options(self, validator):
        validator.require(('name', 'provider', 'url'))

        provider_type = self.get_option('provider', '').lower()
        provider_specific_opts = self.PROVIDER_REQUIRED_OPTS.get(provider_type, tuple())
        validator.require(provider_specific_opts)

    def run(self):
        resource = self.api.create(self.get_option_dict())
        test_foreman_record(resource, 'compute_resource',
            _("Compute resource [ %s ] created.") % self.get_option("name"),
            _("Could not create compute resource [ %s ].") % self.get_option("name")
        )



class Update(ComputeResourceAction):

    description = _('update compute resource')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='original_name', help=_("Compute resource name (required)"))
        parser.add_option('--new_name', dest='name', help=_("New compute resource name"))
        parser.add_option('--url', dest='url', type='url', help=_("URL for Libvirt, Ovirt, and Openstack"))
        parser.add_option('--description', dest='description', help=_(""))
        parser.add_option('--user', dest='user',
            help=_("Username for Ovirt, Vmware, Openstack. Access Key for EC2."))
        parser.add_option('--password', dest='password',
            help=_("Password for Ovirt, Vmware, Openstack. Secret key for EC2"))
        parser.add_option('--uuid', dest='uuid', help=_("for Ovirt, Vmware Datacenter"))
        parser.add_option('--region', dest='region', help=_("for EC2 only"))
        parser.add_option('--tenant', dest='tenant', help=_("for Openstack only"))
        parser.add_option('--server', dest='server', help=_("for Vmware"))

    def check_options(self, validator):
        validator.require('original_name')

    def run(self):
        resource = self.api.update(self.get_option("original_name"), self.get_option_dict())
        test_foreman_record(resource, 'compute_resource',
            _("Compute resource [ %s ] updated.") % self.get_option("original_name"),
            _("Could not update compute resource [ %s ].") % self.get_option("original_name")
        )


class Delete(ComputeResourceAction):

    description = _('destroy compute resource')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name', help=_("compute resource name (required)"))

    def check_options(self, validator):
        validator.require('name')

    def run(self):
        self.api.destroy(self.get_option('name'))
        print _('Compute Resource [ %s ] deleted.') % self.get_option('name')



# compute resource command ------------------------------------------------------------

class ComputeResource(Command):

    description = _('Compute resources specific actions in the katello server')


