import unittest
from mock import Mock
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.user_role
from katello.client.core.user_role import Info



class RequiredCLIOptionsTests(CLIOptionTestCase):
    #takes only name of the role
    def setUp(self):
        self.set_action(Info())
        self.mock_options()

    def test_missing_name_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['info'])

    def test_no_error_if_name_provided(self):
        self.action.process_options(['status', '--name=role1'])
        self.assertEqual(len(self.action.optErrors), 0)



class UserRoleInfoTest(CLIActionTestCase):

    ROLE = test_data.USER_ROLES[0]
    PERMISSIONS = test_data.PERMISSIONS

    OPTIONS = {
        'name': ROLE['name'],
    }

    def setUp(self):
        self.set_action(Info())
        self.set_module(katello.client.core.user_role)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'role', self.ROLE)
        self.mock(self.action.api, 'roles', [self.ROLE])
        self.mock(self.action, 'getPermissions', self.PERMISSIONS)

    def test_finds_role(self):
        self.mock(self.action.api, 'ldap_groups', [])
        self.run_action()
        self.action.api.roles.assert_called_once_with({'name': self.ROLE['name']})

    def test_returns_error_when_no_role_found(self):
        self.mock(self.action.api, 'roles', [])
        self.assertRaises(Exception, self.action.run)

    def test_returns_ok(self):
        self.mock(self.action.api, 'ldap_groups', [])
        self.run_action(os.EX_OK)
