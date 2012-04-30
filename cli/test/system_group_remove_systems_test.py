import unittest
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.system_group
from katello.client.core.system_group import RemoveSystems


class RequiredCLIOptionsTests(CLIOptionTestCase):
    #requires: organization, name

    def setUp(self):
        self.set_action(RemoveSystems())
        self.mock_options()

    def test_missing_org_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['remove_systems', '--name=system_group_1', '--system_ids=34-453sa,agt754ad'])

    def test_missing_name_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['remove_systems', '--org=ACME', '--system_ids=34-453sa, agt754ad'])

    def test_missing_system_ids_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['remove_systems', '--org=ACME', '--name=system_group_1'])

    def test_no_error_if_org_and_name_and_system_ids_provided(self):
        self.action.process_options(['remove_systems', '--org=ACME', '--name=system_group_1', '--system_ids=34-453sa,agt754ad'])
        self.assertEqual(len(self.action.optErrors), 0)


class SystemGroupRemoveSystemsTest(CLIActionTestCase):

    ORG = test_data.ORGS[0]
    SYSTEM_GROUP = test_data.SYSTEM_GROUPS[1]

    OPTIONS = {
        'org': ORG['name'],
        'name': SYSTEM_GROUP['name'],
        'system_ids' : 'fgadg3943-daf323,34ad5-34ad3-h6ddss4'
    }

    def setUp(self):
        self.set_action(RemoveSystems())
        self.set_module(katello.client.core.system_group)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'remove_systems', self.SYSTEM_GROUP)
        self.mock(self.module, 'get_system_group', self.SYSTEM_GROUP)

    def test_it_calls_system_group_remove_systems_api(self):
        self.action.run()
        self.action.api.remove_systems.assert_called_once_with(self.OPTIONS['org'], self.SYSTEM_GROUP['id'], self.OPTIONS['system_ids'])

    def test_it_returns_error_when_adding_failed(self):
        self.mock(self.action.api, 'remove_systems', None)
        self.assertEqual(self.action.run(), os.EX_DATAERR)

    def test_it_success_on_successful_add_of_systems(self):
        self.assertEqual(self.action.run(), os.EX_OK)
