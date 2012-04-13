import unittest
from mock import Mock
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.permission
from katello.client.core.permission import List

class RequiredCLIOptionsTests(CLIOptionTestCase):
    #takes only name of the role
    def setUp(self):
        self.set_action(List())
        self.mock_options()

    def test_missing_role_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['list'])

    def test_no_error_if_role_provided(self):
        self.action.process_options(['status', '--user_role=role1'])
        self.assertEqual(len(self.action.optErrors), 0)




class PermissionListTest(CLIActionTestCase):

    ROLE = test_data.USER_ROLES[0]
    PERMISSIONS = test_data.PERMISSIONS

    OPTIONS = {
        'user_role': ROLE['name'],
    }


    def setUp(self):
        self.set_action(List())
        self.set_module(katello.client.core.permission)
        self.mock_printer()
        self.mock_options(self.OPTIONS)

        self.mock(self.module, 'get_role', self.ROLE)
        self.mock(self.action.api, 'permissions', self.PERMISSIONS)

    def test_finds_role(self):
        self.action.run()
        self.module.get_role.assert_called_once()

    def test_returns_error_when_no_role_found(self):
        self.mock(self.module, 'get_role', None)
        self.assertEqual(self.action.run(), os.EX_DATAERR)

    def test_calls_permission_api(self):
        self.action.run()
        self.action.api.permissions.assert_called_once_with(self.ROLE['id'])

    def test_returns_ok(self):
        self.assertEqual(self.action.run(), os.EX_OK)

    def test_it_prints_the_permissions(self):
        self.action.run()
        self.action.printer.print_items.assert_called_once()
