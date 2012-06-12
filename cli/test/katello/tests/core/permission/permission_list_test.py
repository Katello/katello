import unittest
from mock import Mock
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase

from katello.tests.core.permission import permission_data
from katello.tests.core.user import user_data

import katello.client.core.permission
from katello.client.core.permission import List
from katello.client.api.utils import ApiDataError

class RequiredCLIOptionsTests(CLIOptionTestCase):
    #takes only name of the role
    action = List()

    disallowed_options = [
        ()
    ]

    allowed_options = [
        ('--user_role=role1', )
    ]



class PermissionListTest(CLIActionTestCase):

    ROLE = user_data.USER_ROLES[0]
    PERMISSIONS = permission_data.PERMISSIONS

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
        self.run_action()
        self.module.get_role.assert_called_once()

    def test_returns_error_when_no_role_found(self):
        self.mock(self.module, 'get_role').side_effect = ApiDataError
        self.run_action(os.EX_DATAERR)

    def test_calls_permission_api(self):
        self.run_action()
        self.action.api.permissions.assert_called_once_with(self.ROLE['id'])

    def test_returns_ok(self):
        self.run_action(os.EX_OK)

    def test_it_prints_the_permissions(self):
        self.run_action()
        self.action.printer.print_items.assert_called_once()
