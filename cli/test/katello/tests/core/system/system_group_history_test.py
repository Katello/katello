import unittest
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase
from katello.tests.core.organization import organization_data
from katello.tests.core.system import system_data

import katello.client.core.system_group
from katello.client.core.system_group import History

class RequiredCLIOptionsTests(CLIOptionTestCase):
    action = History()

    disallowed_options = [
        (),
        ('--org=ACME',),
        ('--name=TestGroup')
    ]

    allowed_options = [
        ('--org=ACME','--name=TestGroup')
    ]

class SystemGroupHistoryTest(CLIActionTestCase):

    ORG = organization_data.ORGS[0]
    SYSTEM_GROUP = system_data.SYSTEM_GROUPS[0]

    OPTIONS = {
        'org': ORG['name'],
        'name': SYSTEM_GROUP['name']
    }

    def setUp(self):
        self.set_action(History())
        self.set_module(katello.client.core.system_group)
        self.mock_printer()

        self.mock_options(self.OPTIONS)
        self.mock(self.module, 'get_system_group', self.SYSTEM_GROUP)
        self.mock(self.action.api, 'system_group_history', system_data.SYSTEM_GROUP_HISTORY)

    def test_it_calls_system_groups_api(self):
        self.action.run()
        self.action.api.system_group_history.assert_called_once_with(self.OPTIONS['org'], system_data.SYSTEM_GROUPS[0]['id'])

    def test_it_prints_the_system_groups(self):
        self.action.run()
        expected = [dict(system_data.SYSTEM_GROUP_HISTORY[0].items() + {'tasks': 1, 'parameters': 'packages: foo\n'}.items())]
        self.action.printer.print_items.assert_called_once_with(expected)
