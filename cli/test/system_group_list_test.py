import unittest
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.system_group
from katello.client.core.system_group import List



class RequiredCLIOptionsTests(CLIOptionTestCase):
    #requires: organization

    action = List()

    disallowed_options = [
        ()
    ]

    allowed_options = [
        ('--org=ACME',)
    ]


class SystemGroupListTest(CLIActionTestCase):

    ORG = test_data.ORGS[0]

    OPTIONS = {
        'org': ORG['name'],
    }

    def setUp(self):
        self.set_action(List())
        self.set_module(katello.client.core.system_group)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'system_groups', test_data.SYSTEM_GROUPS)

    def test_it_calls_system_groups_api(self):
        self.action.run()
        self.action.api.system_groups.assert_called_once_with(self.OPTIONS['org'])

    def test_it_prints_the_system_groups(self):
        self.action.run()
        self.action.printer.print_items.assert_called_once_with(test_data.SYSTEM_GROUPS)
