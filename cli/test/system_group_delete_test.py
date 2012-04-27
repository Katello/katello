import unittest
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.system_group
from katello.client.core.system_group import Delete


class RequiredCLIOptionsTests(CLIOptionTestCase):
    #requires: organization, name

    def setUp(self):
        self.set_action(Delete())
        self.mock_options()

    def test_missing_org_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['delete', '--name=system_group_1'])

    def test_missing_name_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['delete', '--org=ACME'])

    def test_no_error_if_org_and_name_provided(self):
        self.action.process_options(['delete', '--org=ACME', '--name=system_group_1'])
        self.assertEqual(len(self.action.optErrors), 0)


class SystemGroupDeleteTest(CLIActionTestCase):

    ORG = test_data.ORGS[0]
    SYSTEM_GROUP = test_data.SYSTEM_GROUPS[1]

    OPTIONS = {
        'org': ORG['name'],
        'name': SYSTEM_GROUP['name']
    }

    def setUp(self):
        self.set_action(Delete())
        self.set_module(katello.client.core.system_group)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'delete', self.SYSTEM_GROUP)
        self.mock(self.module, 'get_system_group', self.SYSTEM_GROUP)

    def test_it_calls_system_group_delete_api(self):
        self.action.run()
        self.action.api.delete.assert_called_once_with(self.OPTIONS['org'], self.SYSTEM_GROUP["id"])

    def test_it_returns_error_when_deletion_failed(self):
        self.mock(self.action.api, 'delete', None)
        self.assertEqual(self.action.run(), os.EX_DATAERR)

    def test_it_prints_on_successful_delete(self):
        self.assertEqual(self.action.run(), os.EX_OK)
