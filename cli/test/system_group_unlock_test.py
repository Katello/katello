import unittest
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.system_group
from katello.client.core.system_group import Unlock


class RequiredCLIOptionsTests(CLIOptionTestCase):
    #requires: organization, name

    def setUp(self):
        self.set_action(Unlock())
        self.mock_options()

    def test_missing_org_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['unlock', '--name=system_group_1'])

    def test_missing_name_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['unlock', '--org=ACME'])

    def test_no_error_if_org_and_name_provided(self):
        self.action.process_options(['unlock', '--org=ACME', '--name=system_group_1'])
        self.assertEqual(len(self.action.optErrors), 0)


class SystemGroupUnlockTest(CLIActionTestCase):

    ORG = test_data.ORGS[0]
    SYSTEM_GROUP = test_data.SYSTEM_GROUPS[0]

    OPTIONS = {
        'org': ORG['name'],
        'name': SYSTEM_GROUP['name']
    }

    def setUp(self):
        self.set_action(Unlock())
        self.set_module(katello.client.core.system_group)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.module, 'get_system_group', self.SYSTEM_GROUP)
        self.mock(self.action.api, 'unlock', self.SYSTEM_GROUP)

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

    def test_it_calls_the_system_group_unlock_api(self):
        self.action.run()
        self.action.api.unlock.assert_called_once_with(self.OPTIONS['org'], self.SYSTEM_GROUP['id'])

    def test_it_returns_error_when_system_group_unlock_not_found(self):
        self.mock(self.action.api, 'unlock', None)
        self.assertEqual(self.action.run(), os.EX_DATAERR)

    def test_it_returns_success_when_system_group_unlock_found(self):
        self.assertEqual(self.action.run(), os.EX_OK)

    def test_it_prints_the_system_group_unlock_success_message(self):
        self.action.run()
        self.action.printer.print_items.assert_called_once()   
