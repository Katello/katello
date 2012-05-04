import unittest
from mock import Mock
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.user_role
from katello.client.core.user_role import AddLdapGroup

class RequiredCLIOptionsTests(CLIOptionTestCase):
    def setUp(self):
        self.set_action(AddLdapGroup())
        self.mock_options()

    def test_missing_name_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['add_ldap_group', '--group_name=test'])

    def test_missing_group_name_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['add_ladp_group', '--name=role1'])

    def test_no_error_if_name_and_group_name_provided(self):
        self.action.process_options(['add_ldap_group', '--name=role1', '--group_name=test'])
        self.assertEqual(len(self.action.optErrors), 0)


class UserRoleAddLdapGroupTest(CLIActionTestCase):

    ROLE = test_data.USER_ROLES[0]

    OPTIONS = {
        'name': ROLE['name'],
        'group_name': 'test'
    }

    def setUp(self):
        self.set_action(AddLdapGroup())
        self.set_module(katello.client.core.user_role)
        self.mock_printer()

        self.mock_options(self.OPTIONS)
        
        self.mock(self.action.api, 'roles', [self.ROLE])
        self.mock(self.action.api, 'add_ldap_group', [])

    def test_it_calls_add_ldap_group_api(self):
        self.action.run()
        self.action.api.add_ldap_group.assert_called_once_with(self.ROLE['id'], 'test')
