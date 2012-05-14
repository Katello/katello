import unittest
from mock import Mock
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.user_role
from katello.client.core.user_role import List

class UserRoleListTest(CLIActionTestCase):

    def setUp(self):
        self.set_action(List())
        self.set_module(katello.client.core.user_role)
        self.mock_printer()
        self.mock_options({})

        self.mock(self.action.api, 'roles', test_data.USER_ROLES[0])

    def test_finds_roles(self):
        self.run_action()
        self.action.api.roles.assert_called_once()

    def test_returns_ok(self):
        self.run_action(os.EX_OK)
