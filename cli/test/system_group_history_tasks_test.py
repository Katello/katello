import unittest
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

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

    ORG = test_data.ORGS[0]
    SYSTEM_GROUP = test_data.SYSTEM_GROUPS[0]

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
        self.mock(self.action.api, 'system_group_history', test_data.SYSTEM_GROUP_HISTORY)

    def test_it_calls_system_groups_api(self):
        self.action.run()
        self.action.api.system_group_history.assert_called_once_with(self.OPTIONS['org'], test_data.SYSTEM_GROUPS[0]['id'], {'job_id':'1'})

    def test_it_prints_the_system_groups(self):
        self.action.run()
        expected = test_data.SYSTEM_GROUP_HISTORY[0]['tasks']
        self.action.printer.print_items.assert_called_once_with(expected) 
