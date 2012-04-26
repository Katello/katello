import unittest
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.system_group
from katello.client.core.system_group import List



class RequiredCLIOptionsTests(CLIOptionTestCase):
    #requires: organization

    def setUp(self):
        self.set_action(List())
        self.mock_options()

    def test_missing_org_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['list', ''])

    def test_no_error_if_org_provided(self):
        self.action.process_options(['list', '--org=ACME'])
        self.assertEqual(len(self.action.optErrors), 0)


class SystemGroupListTest(CLIActionTestCase):

    ORG = test_data.ORGS[0]

    OPTIONS = {
        'org': ORG['name'],
    }

    def setUp(self):
        self.set_action(List())
        self.set_module(katello.client.core.system_group)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'system_groups', test_data.SYSTEM_GROUPS)

    def test_it_calls_system_groups_api(self):
        self.action.run()
        self.action.api.system_groups.assert_called_once_with(self.OPTIONS['org'])

    def test_it_prints_the_system_groups(self):
        self.action.run()
        self.action.printer.printItems.assert_called_once_with(test_data.SYSTEM_GROUPS)
