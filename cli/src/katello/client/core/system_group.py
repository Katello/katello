# -*- coding: utf-8 -*-
#
# Copyright © 2011 Red Hat, Inc.
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
import os
import sys
from gettext import gettext as _

from katello.client.config import Config
from katello.client.core.base import Action, Command
from katello.client.api.system_group import SystemGroupAPI
from katello.client.api.utils import get_system_group
from katello.client.core.utils import is_valid_record


Config()


# base system group action --------------------------------------------------------
class SystemGroup(Command):

    description = _('system group specific actions in the katello server')


class SystemGroupAction(Action):

    def __init__(self):
        super(SystemGroupAction, self).__init__()
        self.api = SystemGroupAPI()

# system group actions ------------------------------------------------------------


class List(SystemGroupAction):

    description = _('list system groups within an organization')

    def setup_parser(self, parser):
        parser.add_option('--org', dest='org',
                       help=_("organization name eg: foo.example.com (required)"))

    def check_options(self, validator):
        validator.require(('org',))

    def run(self):
        org_name = self.get_option('org')

        system_groups = self.api.system_groups(org_name)

        self.printer.set_header(_("System Groups List For Org [ %s ]") % org_name)

        if system_groups is None:
            return os.EX_DATAERR

        self.printer.add_column('id')
        self.printer.add_column('name')

        self.printer._grep = True
        self.printer.print_items(system_groups)
        return os.EX_OK


class Create(SystemGroupAction):

    description = _('create a system group')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name',
                               help=_("system group name (required)"))
        parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))
        parser.add_option('--max_systems', dest='max_systems',
                               help=_("maximum number of systems in this group"))
        parser.add_option('--description', dest='description',
                               help=_("system group description"))

    def check_options(self, validator):
        validator.require(('name', 'org'))

    def run(self):
        org_name = self.get_option('org')
        name = self.get_option('name')
        description = self.get_option('description')
        max_systems = self.get_option('max_systems')

        system_group = self.api.create(org_name, name, description, max_systems)

        if is_valid_record(system_group):
            print _("Successfully created system group [ %s ]") % system_group['name']
            return os.EX_OK
        else:
            print >> sys.stderr, _("Could not create system group [ %s ]") % name
            return os.EX_DATAERR


class Info(SystemGroupAction):

    description = _('display a system group within an organization')

    def setup_parser(self, parser):
        parser.add_option('--org', dest='org',
                       help=_("organization name eg: foo.example.com (required)"))
        parser.add_option('--name', dest='name',
                       help=_("system group name (required)"))

    def check_options(self, validator):
        validator.require(('name', 'org'))

    def run(self):
        org_name = self.get_option('org')
        system_group_name = self.get_option('name')

        self.printer.set_header(_("System Group Information For Org [ %s ]") % (org_name))

        # get system details
        system_group = get_system_group(org_name, system_group_name)

        if not system_group:
            return os.EX_DATAERR

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('description', multiline=True)
        self.printer.add_column('locked')

        self.printer.print_item(system_group)

        return os.EX_OK


class History(SystemGroupAction):

    description = _('display the list of jobs for the specified system group.')

    def setup_parser(self, parser):
        parser.add_option('--org', dest='org',
                       help=_("organization name eg: foo.example.com (required)"))
        parser.add_option('--name', dest='name',
                       help=_("system group name (required)"))

    def check_options(self, validator):
        validator.require(('name', 'org'))

    def run(self):
        org_name = self.get_option('org')
        system_group_name = self.get_option('name')

        self.printer.set_header(_("System Group History For [ %s ]") % (system_group_name))

        system_group = get_system_group(org_name, system_group_name)

        if not system_group:
            return os.EX_DATAERR


        # get list of jobs 
        history = self.api.system_group_history(org_name, system_group['id'])

        for job in history:
            job['tasks'] = len(job['tasks'])
            params = ""
            for key, value in job['parameters'].items():
                params += key + ": " + (', ').join(value) + "\n"
            job['parameters'] = params


        self.printer.add_column('id')
        self.printer.add_column('task_type', name='Type')
        self.printer.add_column('parameters', multiline=True)
        self.printer.add_column('tasks')
        self.printer.print_items(history)

        return os.EX_OK

class HistoryTasks(SystemGroupAction):
    description = _('display job information including individual system tasks')

    def setup_parser(self, parser):
        parser.add_option('--org', dest='org',
                       help=_("organization name eg: foo.example.com (required)"))
        parser.add_option('--name', dest='name',
                       help=_("system group name (required)"))
        parser.add_option('--job_id', dest='job_id',
                       help=_("Job ID to list tasks for (required)"))

    def check_options(self, validator):
        validator.require(('name', 'org', 'job_id'))

    def run(self):
        org_name = self.get_option('org')
        system_group_name = self.get_option('name')
        job_id = self.get_option('job_id')
        # info is always grep friendly

        self.printer.set_header(_("System Group Job tasks For [ %s ]") % (system_group_name))

        system_group = get_system_group(org_name, system_group_name)

        # get list of jobs 
        history = self.api.system_group_history(org_name, system_group['id'], {'job_id':job_id})
        if len(history) == 0:
            print >> sys.stderr, _("Could not find job [ %s ] for system group [ %s ]") % (job_id, system_group_name)
            return os.EX_DATAERR

        tasks = history[0]['tasks']

        self.printer.add_column('id', name='task id')
        self.printer.add_column('uuid', name='system uuid')
        self.printer.add_column('state',)
        self.printer.add_column('progress')
        self.printer.add_column('start_time')
        self.printer.add_column('finish_time')
        self.printer.print_items(tasks)


class Update(SystemGroupAction):

    description = _('update a system group')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name',
                               help=_("system group name (required)"))
        parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))
        parser.add_option('--new_name', dest='new_name',
                              help=_("new system group name"))
        parser.add_option('--max_systems', dest='max_systems',
                               help=_("maximum number of systems in this group (enter -1 for unlimited)"))
        parser.add_option('--description', dest='new_description',
                               help=_("new description"))

    def check_options(self, validator):
        validator.require(('name', 'org'))

    def run(self):
        org_name = self.get_option('org')
        name = self.get_option('name')
        new_name = self.get_option('new_name')
        new_description = self.get_option('new_description')
        max_systems = self.get_option('max_systems')

        system_group = get_system_group(org_name, name)

        if system_group is None:
            return os.EX_DATAERR

        system_group = self.api.update(org_name, system_group["id"], new_name, new_description, max_systems)

        if system_group != None:
            print _("Successfully updated system group [ %s ]") % system_group['name']
            return os.EX_OK
        else:
            return os.EX_DATAERR


class Delete(SystemGroupAction):

    description = _('delete a system group')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name',
                               help=_("system group name (required)"))
        parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))

    def check_options(self, validator):
        validator.require(('name', 'org'))

    def run(self):
        org_name = self.get_option('org')
        name = self.get_option('name')

        system_group = get_system_group(org_name, name)
        if not system_group:
            return os.EX_DATAERR

        message = self.api.delete(org_name, system_group["id"])

        if message != None:
            print message
            return os.EX_OK
        else:
            return os.EX_DATAERR


class Systems(SystemGroupAction):

    description = _('display the systems in a system group')

    def setup_parser(self, parser):
        parser.add_option('--org', dest='org',
                       help=_("organization name eg: foo.example.com (required)"))
        parser.add_option('--name', dest='name',
                       help=_("system group name (required)"))

    def check_options(self, validator):
        validator.require(('name', 'org'))

    def run(self):
        org_name = self.get_option('org')
        system_group_name = self.get_option('name')
        # info is always grep friendly

        # get system details
        system_group = get_system_group(org_name, system_group_name)
        if not system_group:
            return os.EX_DATAERR

        systems = self.api.system_group_systems(org_name, system_group["id"])

        if systems is None:
            return os.EX_DATAERR

        self.printer.set_header(_("Systems within System Group [ %s ] For Org [ %s ]") % (system_group["name"], org_name))

        self.printer.add_column('id')
        self.printer.add_column('name')

        self.printer.print_items(systems)

        return os.EX_OK


class Lock(SystemGroupAction):

    description = _('lock a system group')

    def setup_parser(self, parser):
        parser.add_option('--org', dest='org',
                       help=_("organization name eg: foo.example.com (required)"))
        parser.add_option('--name', dest='name',
                       help=_("system group name (required)"))

    def check_options(self, validator):
        validator.require(('name', 'org'))

    def run(self):
        org_name = self.get_option('org')
        system_group_name = self.get_option('name')
        # info is always grep friendly

        # get system details
        system_group = get_system_group(org_name, system_group_name)
        if not system_group:
            return os.EX_DATAERR

        system_group = self.api.lock(org_name, system_group["id"])

        if system_group != None:
            print _("Successfully locked system group [ %s ]") % system_group['name']
            return os.EX_OK
        else:
            return os.EX_DATAERR


class Unlock(SystemGroupAction):

    description = _('unlock a system group')

    def setup_parser(self, parser):
        parser.add_option('--org', dest='org',
                       help=_("organization name eg: foo.example.com (required)"))
        parser.add_option('--name', dest='name',
                       help=_("system group name (required)"))

    def check_options(self, validator):
        validator.require(('name', 'org'))

    def run(self):
        org_name = self.get_option('org')
        system_group_name = self.get_option('name')
        # info is always grep friendly

        # get system details
        system_group = get_system_group(org_name, system_group_name)
        if not system_group:
            return os.EX_DATAERR

        system_group = self.api.unlock(org_name, system_group["id"])

        if system_group != None:
            print _("Successfully unlocked system group [ %s ]") % system_group['name']
            return os.EX_OK
        else:
            return os.EX_DATAERR


class AddSystems(SystemGroupAction):

    description = _('add systems to a system group')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name',
                               help=_("system group name (required)"))
        parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))
        parser.add_option('--system_uuids', dest='system_uuids', type="list",
                              help=_("comma separated list of system uuids (required)"))

    def check_options(self, validator):
        validator.require(('name', 'org', 'system_uuids'))

    def run(self):
        org_name = self.get_option('org')
        name = self.get_option('name')
        system_ids = self.get_option('system_uuids')

        system_group = get_system_group(org_name, name)

        if system_group is None:
            return os.EX_DATAERR

        systems = self.api.add_systems(org_name, system_group["id"], system_ids)

        if systems != None:
            print _("Successfully added systems to system group [ %s ]") % system_group['name']
            return os.EX_OK
        else:
            return os.EX_DATAERR


class RemoveSystems(SystemGroupAction):

    description = _('remove systems from a system group')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name',
                               help=_("system group name (required)"))
        parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))
        parser.add_option('--system_uuids', dest='system_uuids', type="list",
                              help=_("comma separated list of system uuids (required)"))

    def check_options(self, validator):
        validator.require(('name', 'org', 'system_uuids'))

    def run(self):
        org_name = self.get_option('org')
        name = self.get_option('name')
        system_ids = self.get_option('system_uuids')

        system_group = get_system_group(org_name, name)

        if system_group is None:
            return os.EX_DATAERR

        systems = self.api.remove_systems(org_name, system_group["id"], system_ids)

        if systems != None:
            print _("Successfully removed systems from system group [ %s ]") % system_group['name']
            return os.EX_OK
        else:
            return os.EX_DATAERR
