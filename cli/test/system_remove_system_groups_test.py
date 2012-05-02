import unittest
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.system
from katello.client.core.system import RemoveSystemGroups
from katello.client.api.system_group import SystemGroupAPI


class RequiredCLIOptionsTests(CLIOptionTestCase):
    #requires: organization, name

    def setUp(self):
        self.set_action(RemoveSystemGroups())
        self.mock_options()

    def test_missing_org_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['remove_system_groups', '--name=system_1', '--system_groups=Bob,SystemGroup1'])

    def test_missing_name_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['remove_system_groups', '--org=ACME', '--system_groups=SysG1'])

    def test_missing_system_groups_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['remove_system_groups', '--org=ACME', '--name=system_1'])

    def test_no_error_if_org_and_name_and_system_groups_provided(self):
        self.action.process_options(['remove_system_groups', '--org=ACME', '--name=system_1', '--system_groups=Here,There,Where'])
        self.assertEqual(len(self.action.optErrors), 0)


class SystemRemoveSystemGroupsTest(CLIActionTestCase):

    ORG = test_data.ORGS[0]
    SYSTEM = test_data.SYSTEMS[0]
    SYSTEM_GROUP_1 = test_data.SYSTEM_GROUPS[0]
    SYSTEM_GROUP_2 = test_data.SYSTEM_GROUPS[1]

    OPTIONS = {
        'org': ORG['name'],
        'name': SYSTEM['name'],
        'system_groups' : [SYSTEM_GROUP_1['id'], SYSTEM_GROUP_2['id']]
    }

    def setUp(self):
        self.set_action(RemoveSystemGroups())
        self.set_module(katello.client.core.system)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'remove_system_groups', self.SYSTEM)
        self.mock(self.action.api, 'systems_by_org', [self.SYSTEM])
        self.mock(SystemGroupAPI, 'system_groups', [self.SYSTEM_GROUP_1, self.SYSTEM_GROUP_2])

    def test_it_calls_system_remove_system_groups_api(self):
        self.action.run()
        self.action.api.remove_system_groups.assert_called_once_with(self.SYSTEM['uuid'], self.OPTIONS['system_groups'])

    def test_it_returns_error_when_adding_failed(self):
        self.mock(self.action.api, 'remove_system_groups', None)
        self.assertEqual(self.action.run(), os.EX_DATAERR)

    def test_it_returns_success_on_successful_add_of_system_groups(self):
        self.assertEqual(self.action.run(), os.EX_OK)
