import unittest
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase
from katello.tests.core.organization import organization_data
from katello.tests.core.system import system_data
from katello.tests.core.activation_key import activation_key_data as ak_data

import katello.client.core.activation_key
from katello.client.core.activation_key import RemoveSystemGroup
from katello.client.api.system_group import SystemGroupAPI


class RequiredCLIOptionsTests(CLIOptionTestCase):
    #requires: organization, name

    action = RemoveSystemGroup()

    disallowed_options = [
        (),
        ('--org=ACME',),
        ('--name=system_group_1',),
        ('--system_groupds=SysG1')
    ]

    allowed_options = [
        ('--org=ACME', '--name=system_group_1', '--system_group=SysG2')
    ]


class ActivationKeyRemoveSystemGroupGroupsTest(CLIActionTestCase):

    ORG = organization_data.ORGS[0]
    ACTIVATION_KEY = ak_data.ACTIVATION_KEYS[0]
    SYSTEM_GROUP_1 = system_data.SYSTEM_GROUPS[0]
    SYSTEM_GROUP_2 = system_data.SYSTEM_GROUPS[1]

    OPTIONS = {
        'org': ORG['name'],
        'name': ACTIVATION_KEY['name'],
        'system_group' : SYSTEM_GROUP_1['id']
    }

    def setUp(self):
        self.set_action(RemoveSystemGroup())
        self.set_module(katello.client.core.activation_key)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'remove_system_group', self.ACTIVATION_KEY)
        self.mock(self.action.api, 'activation_keys_by_organization', [self.ACTIVATION_KEY])
        self.mock(SystemGroupAPI, 'system_groups', [self.SYSTEM_GROUP_1])
        self.mock(self.module.sys, "stderr", None)

    def test_it_calls_system_remove_system_group_api(self):
        self.action.run()
        self.action.api.remove_system_group.assert_called_once_with(self.OPTIONS['org'], self.ACTIVATION_KEY['id'], self.OPTIONS['system_group'])

    def test_it_returns_error_when_adding_failed(self):
        self.mock(self.action.api, 'remove_system_group', None)
        self.assertEqual(self.action.run(), os.EX_DATAERR)

    def test_it_returns_success_on_successful_add_of_system_groups(self):
        self.assertEqual(self.action.run(), os.EX_OK)
