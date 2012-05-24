import unittest
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.system_group
from katello.client.core.system_group import AddSystems


class RequiredCLIOptionsTests(CLIOptionTestCase):
    #requires: organization, name, system uuids

    action = AddSystems()

    disallowed_options = [
        (),
        ('--org=ACME', ),
        ('--name=system_group_1',),
        ('--system_uuids=345'),
        ('--org=ACME', '--name=system_group_1'),
        ('--org=ACME', '--system_uuids=345'),
        ('--name=system_group_1', '--system_uuids=456')
    ]

    allowed_options = [
        ('--org=ACME', '--name=system', '--system_uuids=4948857'),
    ]


class SystemGroupAddSystemsTest(CLIActionTestCase):

    ORG = test_data.ORGS[0]
    SYSTEM_GROUP = test_data.SYSTEM_GROUPS[1]

    OPTIONS = {
        'org': ORG['name'],
        'name': SYSTEM_GROUP['name'],
        'system_uuids' : 'fgadg3943-daf323,34ad5-34ad3-h6ddss4'
    }

    def setUp(self):
        self.set_action(AddSystems())
        self.set_module(katello.client.core.system_group)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'add_systems', self.SYSTEM_GROUP)
        self.mock(self.module, 'get_system_group', self.SYSTEM_GROUP)

    def test_it_calls_system_group_add_systems_api(self):
        ids = [id for id in self.OPTIONS['system_uuids'].split(',')]
        self.action.run()
        self.action.api.add_systems.assert_called_once_with(self.OPTIONS['org'], self.SYSTEM_GROUP['id'], ids)

    def test_it_returns_error_when_adding_failed(self):
        self.mock(self.action.api, 'add_systems', None)
        self.assertEqual(self.action.run(), os.EX_DATAERR)

    def test_it_success_on_successful_add_of_systems(self):
        self.assertEqual(self.action.run(), os.EX_OK)
