import unittest
from mock import Mock
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.user_role
from katello.client.core.user_role import RemoveLdapGroup

class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = RemoveLdapGroup()

    disallowed_options = [
        ('--group_name=test', ),
        ('--name=role1', ),
    ]

    allowed_options = [
        ('--name=role1', '--group_name=test'),
    ]


class UserRoleRemoveLdapGroupTest(CLIActionTestCase):

    ROLE = test_data.USER_ROLES[0]

    OPTIONS = {
        'name': ROLE['name'],
        'group_name': 'test'
    }

    def setUp(self):
        self.set_action(RemoveLdapGroup())
        self.set_module(katello.client.core.user_role)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'roles', [self.ROLE])
        self.mock(self.action.api, 'remove_ldap_group', [])

    def test_it_calls_remove_ldap_group_api(self):
        self.run_action()
        self.action.api.remove_ldap_group.assert_called_once_with(self.ROLE['id'], 'test')
