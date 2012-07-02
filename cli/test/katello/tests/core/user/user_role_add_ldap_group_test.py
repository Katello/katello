import unittest
from mock import Mock
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase
from katello.tests.core.user import user_data

import katello.client.core.user_role
from katello.client.core.user_role import AddLdapGroup

class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = AddLdapGroup()

    disallowed_options = [
        ('--group_name=test'),
        ('--name=role1'),
    ]

    allowed_options = [
        ('--name=role1', '--group_name=test'),
    ]


class UserRoleAddLdapGroupTest(CLIActionTestCase):

    ROLE = user_data.USER_ROLES[0]

    OPTIONS = {
        'name': ROLE['name'],
        'group_name': 'test'
    }

    def setUp(self):
        self.set_action(AddLdapGroup())
        self.set_module(katello.client.core.user_role)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'roles', [self.ROLE])
        self.mock(self.action.api, 'add_ldap_group', [])

    def test_it_calls_add_ldap_group_api(self):
        self.run_action()
        self.action.api.add_ldap_group.assert_called_once_with(self.ROLE['id'], 'test')
