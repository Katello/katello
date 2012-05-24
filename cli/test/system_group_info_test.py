import unittest
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.system_group
from katello.client.core.system_group import Info


class RequiredCLIOptionsTests(CLIOptionTestCase):
    #requires: organization, name

    action = Info()

    disallowed_options = [
        (),
        ('--org=ACME',),
        ('--name=system_group_1',)
    ]

    allowed_options = [
        ('--org=ACME', '--name=system_group_1')
    ]


class SystemGroupInfoTest(CLIActionTestCase):

    ORG = test_data.ORGS[0]
    SYSTEM_GROUP = test_data.SYSTEM_GROUPS[0]

    OPTIONS = {
        'org': ORG['name'],
        'name': SYSTEM_GROUP['name']
    }

    def setUp(self):
        self.set_action(Info())
        self.set_module(katello.client.core.system_group)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.module, 'get_system_group', self.SYSTEM_GROUP)

    def test_it_calls_the_system_group_by_name_api(self):
        self.action.run()
        self.module.get_system_group.assert_called_once_with(self.OPTIONS['org'], self.SYSTEM_GROUP['name'])

    def test_it_returns_error_when_system_group_not_found(self):
        self.mock(self.module, 'get_system_group', None)
        self.assertEqual(self.action.run(), os.EX_DATAERR)

    def test_it_returns_success_when_system_group_found(self):
        self.assertEqual(self.action.run(), os.EX_OK)

    def test_it_prints_the_system_group(self):
        self.action.run()
        self.action.printer.print_items.assert_called_once()
