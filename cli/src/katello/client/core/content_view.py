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

from katello.client.api.content_view import ContentViewAPI
from katello.client.api.content_view_definition import ContentViewDefinitionAPI
from katello.client.cli.base import opt_parser_add_org, \
        opt_parser_add_environment
from katello.client.core.base import BaseAction, Command
from katello.client.api.utils import get_environment, get_content_view, \
        get_library
from katello.client.lib.async import AsyncTask, evaluate_task_status
from katello.client.lib.ui.progress import run_spinner_in_bg, wait_for_async_task

# base content_view action --------------------------------------------------------

class ContentViewAction(BaseAction):

    def __init__(self):
        super(ContentViewAction, self).__init__()
        self.api = ContentViewAPI()
        self.def_api = ContentViewDefinitionAPI()

# content_view actions ------------------------------------------------------------


class List(ContentViewAction):

    description = _('list known content views')

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)
        opt_parser_add_environment(parser)

    def check_options(self, validator):
        validator.require('org')

    def run(self):
        org_name = self.get_option('org')
        env_name = self.get_option('environment')

        env = get_environment(org_name, env_name) if env_name else None

        views = self.api.content_views_by_org(org_name, env)

        self.printer.add_column('id', _("ID"))
        self.printer.add_column('name', _("Name"))
        self.printer.add_column('label', _("Label"))
        self.printer.add_column('description', _("Description"), multiline=True)
        self.printer.add_column('organization', _('Org'))
        self.printer.add_column('environments', _('Env'), multiline=True)

        self.printer.set_header(_("Content View List"))
        self.printer.print_items(views)
        return os.EX_OK


class Info(ContentViewAction):

    description = _('list a specific content view')

    def setup_parser(self, parser):
        opt_parser_add_org(parser, True)
        parser.add_option('--label', dest='label',
                help=_("content view label eg: foo.example.com"))
        parser.add_option('--name', dest='name',
                help=_("content view name eg: foo.example.com"))
        parser.add_option('--id', dest='id',
                help=_("content view id eg: 4"))
        parser.add_option('--env', dest='env',
                help=_("environment name (default: Library)"))

    def check_options(self, validator):
        validator.require(('org'))
        validator.require_at_least_one_of(('name', 'label', 'id'))
        validator.mutually_exclude('name', 'label', 'id')

    def run(self):
        org_name = self.get_option('org')
        env_name = self.get_option('env')
        view_label = self.get_option('label')
        view_id = self.get_option('id')
        view_name = self.get_option('name')

        view = get_content_view(org_name, view_label, view_name, view_id)
        if env_name:
            env = get_environment(org_name, env_name)
            env_id = env["id"] if env else None
        else:
            env = get_library(org_name)
            env_id = env["id"] if env else None

        view = self.api.show(org_name, view["id"], env_id)

        self.printer.add_column('id', _("ID"))
        self.printer.add_column('name', _("Name"))
        self.printer.add_column('label', _("Label"))
        self.printer.add_column('description', _("Description"), multiline=True)
        self.printer.add_column('organization', _('Org'))
        self.printer.add_column('definition', _("Definition"))
        self.printer.add_column('environments', _('Environments'),
                                multiline=True)
        self.printer.add_column('versions', _("Versions"), multiline=True)
        self.printer.add_column('repositories', _('Repos'),
                                multiline=True)

        self.printer.set_header(_("ContentView Info"))
        self.printer.print_item(view)
        return os.EX_OK


class Promote(ContentViewAction):

    description = _('promote a content view into an environment')

    def setup_parser(self, parser):
        opt_parser_add_org(parser, True)
        parser.add_option('--label', dest='label',
                          help=_("content view label eg: foo.example.com"))
        parser.add_option('--name', dest='name',
                help=_("content view name eg: foo.example.com"))
        parser.add_option('--id', dest='id',
                help=_("content view id eg: 4"))
        opt_parser_add_environment(parser, True)
        parser.add_option('--async', dest='async', action="store_true",
                help=_("promote asynchronously (default: false)"))

    def check_options(self, validator):
        validator.require(('org', 'environment'))
        validator.require_at_least_one_of(('name', 'label', 'id'))
        validator.mutually_exclude('name', 'label', 'id')

    def run(self):
        org_name = self.get_option('org')
        env_name = self.get_option('environment')
        async = self.get_option('async')
        view_label = self.get_option('label')
        view_id = self.get_option('id')
        view_name = self.get_option('name')

        view = get_content_view(org_name, view_label, view_name, view_id)

        environment = get_environment(org_name, env_name)
        env_id = environment["id"]

        task = self.api.promote(view["id"], env_id)

        if not async:
            task = AsyncTask(task)
            run_spinner_in_bg(wait_for_async_task, [task],
                    message=_("Promoting content view, please wait..."))

            return evaluate_task_status(task,
                failed = _("View [ %s ] promotion failed") % view["name"],
                ok =     _("Content view [ %(view)s ] promoted to environment [ %(env)s ]") %
                    {"view": view["name"], "env": environment["name"]},
            )

        else:
            print _("Promotion task [ %s ] was successfully created.") % (task["uuid"])
            return os.EX_OK


class Refresh(ContentViewAction):

    description = _('regenerate a content view based on its definition in Library')

    def setup_parser(self, parser):
        opt_parser_add_org(parser, True)
        parser.add_option('--label', dest='label',
                          help=_("content view label eg: foo.example.com"))
        parser.add_option('--name', dest='name',
                          help=_("content view name eg: foo.example.com"))
        parser.add_option('--id', dest='id',
                          help=_("content view id eg: 4"))
        parser.add_option('--async', dest='async', action="store_true",
                          help=_("refresh asynchronously (default: false)"))

    def check_options(self, validator):
        validator.require('org')
        validator.require_at_least_one_of(('name', 'label', 'id'))
        validator.mutually_exclude('name', 'label', 'id')

    def run(self):
        org_name = self.get_option('org')
        view_label = self.get_option('label')
        view_id = self.get_option('id')
        view_name = self.get_option('name')
        async = self.get_option('async')

        view = get_content_view(org_name, view_label, view_name, view_id)

        task = self.api.refresh(view["id"])

        if not async:
            task = AsyncTask(task)
            run_spinner_in_bg(wait_for_async_task, [task],
                              message=_("Refreshing view, please wait..."))

            return evaluate_task_status(task,
                ok =     _("Content view [ %s ] was successfully refreshed.") % view["name"],
                failed = _("View [ %s ] refresh failed") % view["name"]
            )

        else:
            print _("Refresh task [ %s ] was successfully created.") % (task["uuid"])
            return os.EX_OK


# content_view command ------------------------------------------------------------

class ContentView(Command):

    description = _('content view specific actions for the katello server')
