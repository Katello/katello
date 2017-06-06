import unittest
from mock import Mock
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase
from katello.tests.core.user import user_data

import katello.client.core.user_role
from katello.client.core.user_role import Create


class RequiredCLIOptionsTests(CLIOptionTestCase):
    #required: name
    #optional: description
    action = Create()

    disallowed_options = [
        (),
    ]

    allowed_options = [
        ('--name=role1', ),
        ('--name=role1', '--description=desc1'),
    ]



class UserRoleCreateTest(CLIActionTestCase):

    ROLE = user_data.USER_ROLES[0]

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
