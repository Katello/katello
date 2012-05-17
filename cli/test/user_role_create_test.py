import unittest
from mock import Mock
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.user_role
from katello.client.core.user_role import Create


class RequiredCLIOptionsTests(CLIOptionTestCase):
    #required: name
    #optional: description
    def setUp(self):
        self.set_action(Create())
        self.mock_options()

    def test_missing_name_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['create'])

    def test_no_error_if_name_provided(self):
        self.action.process_options(['create', '--name=role1'])
        self.assertEqual(len(self.action.optErrors), 0)

    def test_no_error_if_name_and_desc_provided(self):
        self.action.process_options(['create', '--name=role1', '--description=desc1'])
        self.assertEqual(len(self.action.optErrors), 0)


class UserRoleCreateTest(CLIActionTestCase):

    ROLE = test_data.USER_ROLES[0]

    OPTIONS = {
        'name': ROLE['name'],
        'desc': ROLE['description'],
    }

    def setUp(self):
        self.set_action(Create())
        self.set_module(katello.client.core.user_role)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'create', self.ROLE)

    def test_it_creates_role(self):
        self.run_action()
        self.action.api.create.assert_called_once_with(self.ROLE['name'], self.ROLE['description'])

    def test_returns_error_when_role_not_created(self):
        self.mock(self.action.api, 'create', {})
        self.run_action(os.EX_DATAERR)

    def test_returns_ok(self):
        self.run_action(os.EX_OK)
