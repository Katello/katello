import unittest
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.system_group
from katello.client.core.system_group import Update


class RequiredCLIOptionsTests(CLIOptionTestCase):
    #requires: organization, name

    action = Update()

    disallowed_options = [
        (),
        ('--org=ACME',),
        ('--name=system_group_1',)
    ]

    allowed_options = [
        ('--org=ACME', '--name=system_group_1'),
    ]

class SystemGroupUpdateTest(CLIActionTestCase):

    ORG = test_data.ORGS[0]
    SYSTEM_GROUP = test_data.SYSTEM_GROUPS[1]

    OPTIONS = {
        'org': ORG['name'],
        'id' : SYSTEM_GROUP['id'],
        'new_name': SYSTEM_GROUP['name'],
        'new_description': SYSTEM_GROUP['description'],
        'max_systems' : 5
    }

    OPTIONS_NO_DESC = {
        'org': ORG['name'],
        'id' : SYSTEM_GROUP['id'],
        'new_name': SYSTEM_GROUP['name'],
        'max_systems' : 5
    }

    def setUp(self):
        self.set_action(Update())
        self.set_module(katello.client.core.system_group)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.module, 'get_system_group', self.SYSTEM_GROUP)
        self.mock(self.action.api, 'update', self.SYSTEM_GROUP)

    def test_it_calls_system_group_update_api(self):
        self.action.run()
        self.action.api.update.assert_called_once_with(self.OPTIONS['org'], self.OPTIONS['id'], 
                                                        self.OPTIONS["new_name"], self.OPTIONS['new_description'], 
                                                        self.OPTIONS['max_systems'])

    def test_it_calls_system_group_update_name_api(self):
        self.mock_options(self.OPTIONS_NO_DESC)
        self.action.run()
        self.action.api.update.assert_called_once_with(self.OPTIONS['org'], self.OPTIONS['id'], self.OPTIONS["new_name"], None, self.OPTIONS['max_systems'])

    def test_it_returns_error_when_creation_failed(self):
        self.mock(self.action.api, 'update', None)
        self.assertEqual(self.action.run(), os.EX_DATAERR)

    def test_it_success_on_successful_creation(self):
        self.assertEqual(self.action.run(), os.EX_OK)
