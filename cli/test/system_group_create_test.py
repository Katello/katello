import unittest
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.system_group
from katello.client.core.system_group import Create


class RequiredCLIOptionsTests(CLIOptionTestCase):
    #requires: organization, name
    #optional: maximum systems, description

    action = Create()

    disallowed_options = [
        (),
        ('--org=ACME', ),
        ('--name=system_group_1',),
        ('--description="This is a system group"'),
        ('--max_systems=35'),
        ('--org=ACME', '--max_systems=35'),
        ('--org=ACME', '-description="This is a system group"'),
    ]

    allowed_options = [
        ('--org=ACME', '--name=system'),
        ('--org=ACME', '--name=system', '--max_systems=6'),
        ('--org=ACME', '--name=system', '--description="This is a desc"'),
        ('--org=ACME', '--name=system', '--description="This is a desc"', '--max_systems=6')
    ]


class SystemGroupCreateTest(CLIActionTestCase):

    ORG = test_data.ORGS[0]
    SYSTEM_GROUP = test_data.SYSTEM_GROUPS[1]

    OPTIONS = {
        'org': ORG['name'],
        'name': SYSTEM_GROUP['name'],
        'description': SYSTEM_GROUP['description'],
        'max_systems' : 5
    }

    def setUp(self):
        self.set_action(Create())
        self.set_module(katello.client.core.system_group)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'create', self.SYSTEM_GROUP)

    def test_it_calls_system_group_create_api(self):
        self.action.run()
        self.action.api.create.assert_called_once_with(self.OPTIONS['org'], self.OPTIONS['name'],
                                                        self.OPTIONS['description'], self.OPTIONS['max_systems'])

    def test_it_returns_error_when_creation_failed(self):
        self.mock(self.action.api, 'create', {})
        self.assertEqual(self.action.run(), os.EX_DATAERR)

    def test_it_success_on_successful_creation(self):
        self.assertEqual(self.action.run(), os.EX_OK)
