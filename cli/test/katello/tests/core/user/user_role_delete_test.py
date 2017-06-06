import unittest
from mock import Mock
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase
from katello.tests.core.user import user_data

import katello.client.core.user_role
from katello.client.core.user_role import Delete



class RequiredCLIOptionsTests(CLIOptionTestCase):
    #takes only name of the role
    action = Delete()

    disallowed_options = [
        (),
    ]

    allowed_options = [
        ('--name=role1', ),
    ]



class UserRoleDeleteTest(CLIActionTestCase):

    ROLE = user_data.USER_ROLES[0]

    OPTIONS = {
        'name': ROLE['name'],
    }

    def setUp(self):
        self.set_action(Delete())
        self.set_module(katello.client.core.user_role)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'role', self.ROLE)
        self.mock(self.action.api, 'roles', [self.ROLE])
        self.mock(self.action.api, 'delete')

    def test_it_finds_role(self):
        self.run_action()
        self.action.api.roles.assert_called_once_with({'name': self.ROLE['name']})

    def test_it_deletes_role(self):
        self.run_action()
        self.action.api.delete.assert_called_once_with(self.ROLE['id'])

    def test_returns_error_when_no_role_found(self):
        self.mock(self.action.api, 'roles', [])
        self.assertRaises(Exception, self.action.run)

    def test_returns_ok(self):
        self.run_action(os.EX_OK)
