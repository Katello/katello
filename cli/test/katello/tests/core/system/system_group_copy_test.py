import unittest
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase
from katello.tests.core.organization import organization_data
from katello.tests.core.system import system_data

import katello.client.core.system_group
from katello.client.core.system_group import Copy
from katello.client.api.system_group import SystemGroupAPI

class RequiredCLIOptionsTests(CLIOptionTestCase):
    #requires: name, new_name, organization
    #optional: maximum systems, description

    action = Copy()

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
        ('--name=orig_system', '--org=ACME', '--new_name=system'), 
        ('--name=orig_system', '--org=ACME', '--new_name=system', '--max_systems=6'), 
        ('--name=orig_system', '--org=ACME', '--new_name=system', '--description="This is a desc"'),
        ('--name=orig_system', '--org=ACME', '--new_name=system', '--description="This is a desc"', '--max_systems=6')
    ]


class SystemGroupCopyTest(CLIActionTestCase):

    ORG = organization_data.ORGS[0]
    SYSTEM_GROUP = system_data.SYSTEM_GROUPS[1]
    NEW_NAME = SYSTEM_GROUP['name'] + "_copied"

    OPTIONS = {
        'org': ORG['name'],
        'name': SYSTEM_GROUP['name'],
        'new_name': NEW_NAME,
        'description': SYSTEM_GROUP['description'],
        'max_systems' : 5
    }

    def setUp(self):
        self.set_action(Copy())
        self.set_module(katello.client.core.system_group)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'copy', self.SYSTEM_GROUP)
        self.mock(SystemGroupAPI, 'system_group_by_name', self.SYSTEM_GROUP)

    def test_it_calls_system_group_copy_api(self):
        self.run_action()
        self.action.api.copy.assert_called_once_with(self.OPTIONS['org'], self.SYSTEM_GROUP['id'], self.NEW_NAME,
                                                        self.OPTIONS['description'], self.OPTIONS['max_systems'])
