import unittest
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase
from katello.tests.core.organization import organization_data
from katello.tests.core.system import system_data

import katello.client.core.system_group
from katello.client.core.system_group import HistoryTasks

class RequiredCLIOptionsTests(CLIOptionTestCase):
    action = HistoryTasks()

    disallowed_options = [
        (),
        ('--org=ACME',),
        ('--name=TestGroup'),
        ('--job_id=1'),
        ('--org=ACME', '--name=TestGroup')
    ]

    allowed_options = [
        ('--org=ACME','--name=TestGroup', '--job_id=1')
    ]

class SystemGroupHistoryTasksTest(CLIActionTestCase):

    ORG = organization_data.ORGS[0]
    SYSTEM_GROUP = system_data.SYSTEM_GROUPS[0]

    OPTIONS = {
        'org': ORG['name'],
        'name': SYSTEM_GROUP['name'],
        'job_id': '1'
    }

    def setUp(self):
        self.set_action(HistoryTasks())
        self.set_module(katello.client.core.system_group)
        self.mock_printer()

        self.mock_options(self.OPTIONS)
        self.mock(self.module, 'get_system_group', self.SYSTEM_GROUP)
        self.mock(self.action.api, 'system_group_history', system_data.SYSTEM_GROUP_HISTORY[0])

    def test_it_calls_system_groups_api(self):
        self.action.run()
        self.action.api.system_group_history.assert_called_once_with(self.OPTIONS['org'], system_data.SYSTEM_GROUPS[0]['id'], self.OPTIONS['job_id'])

    def test_it_prints_the_system_groups(self):
        self.action.run()
        expected = system_data.SYSTEM_GROUP_HISTORY[0]['tasks']
        self.action.printer.print_items.assert_called_once_with(expected)
