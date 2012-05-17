import unittest
from mock import Mock
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.user_role
from katello.client.core.user_role import Update


class RequiredCLIOptionsTests(CLIOptionTestCase):
    #required: name
    #optional: description
    def setUp(self):
        self.set_action(Update())
        self.mock_options()

    def test_missing_name_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['update'])

    def test_missing_at_least_one_set_parameter_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['update', '--name=role1'])

    def test_no_error_if_new_name_provided(self):
        self.action.process_options(['update', '--name=role1', '--new_name=desc1_2'])
        self.assertEqual(len(self.action.optErrors), 0)

    def test_no_error_if_desc_provided(self):
        self.action.process_options(['update', '--name=role1', '--description=desc1'])
        self.assertEqual(len(self.action.optErrors), 0)


class UserRoleUpdateTest(CLIActionTestCase):

    ROLE = test_data.USER_ROLES[0]
    NEW_NAME = ROLE['name'] +'_2'

    OPTIONS = {
        'name': ROLE['name'],
        'new_name': NEW_NAME,
        'desc': ROLE['description'],
    }

    def setUp(self):
        self.set_action(Update())
        self.set_module(katello.client.core.user_role)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'role', self.ROLE)
        self.mock(self.action.api, 'roles', [self.ROLE])
        self.mock(self.action.api, 'update', self.ROLE)

    def test_finds_role(self):
        self.run_action()
        self.action.api.roles.assert_called_once_with({'name': self.ROLE['name']})

    def test_it_updates_role(self):
        self.run_action()
        self.action.api.update.assert_called_once_with(self.ROLE['id'] , self.NEW_NAME, self.ROLE['description'])

    def test_returns_ok(self):
        self.run_action(os.EX_OK)
