import unittest
from mock import Mock
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.permission
from katello.client.core.permission import Delete
from katello.client.api.utils import ApiDataError

class RequiredCLIOptionsTests(CLIOptionTestCase):
    #required: name, user_role
    def setUp(self):
        self.set_action(Delete())
        self.mock_options()

    def test_missing_name_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['create', '--user_role=role1'])

    def test_missing_role_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['create', '--name=perm1'])

    def test_no_error_if_required_params_provided(self):
        self.action.process_options( ['create', '--name=perm1', '--user_role=role1'])
        self.assertEqual(len(self.action.optErrors), 0)


class PermissionDeleteTest(CLIActionTestCase):

    ROLE = test_data.USER_ROLES[0]
    PERM = test_data.PERMISSIONS[0]

    OPTIONS = {
        'name': PERM['name'],
        'user_role': ROLE['name']
    }

    def setUp(self):
        self.set_action(Delete())
        self.set_module(katello.client.core.permission)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.module, 'get_role', self.ROLE)
        self.mock(self.module, 'get_permission', self.PERM)
        self.mock(self.action.api, 'delete')

    def test_it_finds_role(self):
        self.run_action()
        self.module.get_role.assert_called_once_with(self.ROLE['name'])

    def test_returns_error_when_role_not_found(self):
        self.mock(self.module, 'get_role').side_effect = ApiDataError
        self.run_action(os.EX_DATAERR)

    def test_it_finds_permission(self):
        self.run_action()
        self.module.get_permission.assert_called_once_with(self.ROLE['name'], self.PERM['name'])

    def test_returns_error_when_permission_not_found(self):
        self.mock(self.module, 'get_permission').side_effect = ApiDataError
        self.run_action(os.EX_DATAERR)

    def test_it_deletes_permission(self):
        self.run_action()
        self.action.api.delete.assert_called_once_with(self.ROLE['id'], self.PERM['id'])

    def test_returns_ok(self):
        self.run_action(os.EX_OK)
