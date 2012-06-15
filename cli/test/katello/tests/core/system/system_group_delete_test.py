import unittest
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase
from katello.tests.core.organization import organization_data
from katello.tests.core.system import system_data

import katello.client.core.system_group
from katello.client.core.system_group import Delete


class RequiredCLIOptionsTests(CLIOptionTestCase):
    #requires: organization, name

    action = Delete()

    disallowed_options = [
        (),
        ('--org=ACME',),
        ('--name=system_group_1',)
    ]

    allowed_options = [
        ('--org=ACME', '--name=system_group_1')
    ]


class SystemGroupDeleteTest(CLIActionTestCase):

    ORG = organization_data.ORGS[0]
    SYSTEM_GROUP = system_data.SYSTEM_GROUPS[1]

    OPTIONS = {
        'org': ORG['name'],
        'name': SYSTEM_GROUP['name']
    }

    def setUp(self):
        self.set_action(Delete())
        self.set_module(katello.client.core.system_group)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'delete', self.SYSTEM_GROUP)
        self.mock(self.module, 'get_system_group', self.SYSTEM_GROUP)

    def test_it_calls_system_group_delete_api(self):
        self.action.run()
        self.action.api.delete.assert_called_once_with(self.OPTIONS['org'], self.SYSTEM_GROUP["id"])

    def test_it_returns_error_when_deletion_failed(self):
        self.mock(self.action.api, 'delete', None)
        self.assertEqual(self.action.run(), os.EX_DATAERR)

    def test_it_prints_on_successful_delete(self):
        self.assertEqual(self.action.run(), os.EX_OK)
