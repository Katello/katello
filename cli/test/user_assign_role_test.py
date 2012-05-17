import unittest
from mock import Mock
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.user
from katello.client.core.user import AssignRole
from katello.client.api.utils import ApiDataError


class RequiredCLIOptionsTests(CLIOptionTestCase):
    #takes username and role, both required
    def setUp(self):
        self.set_action(AssignRole())
        self.mock_options()

    def test_missing_role_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['assign_role', '--username=user1'])

    def test_missing_username_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['assign_role', '--role=role1'])

    def test_no_error_if_name_provided(self):
        self.action.process_options(['assign_role', '--username=user1', '--role=role1'])
        self.assertEqual(len(self.action.optErrors), 0)



class UserRoleDeleteTest(CLIActionTestCase):

    ROLE = test_data.USER_ROLES[0]
    USER = test_data.USERS[0]

    OPTIONS = {
        'username': USER['username'],
        'role': ROLE['name']
    }

    def setUp(self):
        self.set_action(AssignRole())
        self.set_module(katello.client.core.user)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.action.role_api, 'role_by_name', self.ROLE)
        self.mock(self.action.api, 'assign_role')
        self.mock(self.action.api, 'unassign_role')
        self.mock(self.module, 'get_user', self.USER)

    def test_it_finds_user(self):
        self.run_action()
        self.module.get_user.assert_called_once_with(self.USER['username'])

    def test_it_finds_role(self):
        self.run_action()
        self.action.role_api.role_by_name.assert_called_once_with(self.ROLE['name'])

    def test_returns_error_when_user_not_found(self):
        self.mock(self.module, 'get_user').side_effect = ApiDataError
        self.run_action(os.EX_DATAERR)

    def test_returns_error_when_role_not_found(self):
        self.mock(self.action.role_api, 'role_by_name', None)
        self.run_action(os.EX_DATAERR)

    def test_it_calls_update_role(self):
        self.mock(self.action, 'update_role')
        self.run_action()
        self.action.update_role.assert_called_once_with(self.USER['id'], self.ROLE['id'])

    def test_it_assigns_role(self):
        self.mock(self.action, 'assign', True)
        self.action.update_role(1, 2)
        self.action.api.assign_role.assert_called_once_with(1, 2)

    def test_it_unassigns_role(self):
        self.mock(self.action, 'assign', False)
        self.action.update_role(1, 2)
        self.action.api.unassign_role.assert_called_once_with(1, 2)

    def test_returns_ok(self):
        self.run_action(os.EX_OK)
