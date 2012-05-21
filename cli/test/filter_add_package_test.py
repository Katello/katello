import unittest
from mock import Mock
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.filters
from katello.client.core.filters import AddPackage

class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = AddPackage()

    disallowed_options = [
        ('--name=filter1', '--package=package1'),
        ('--org=ACME', '--package=package1'),
        ('--org=ACME', '--name=filter1'),
    ]

    allowed_options = [
        ('--org=ACME', '--name=filter1', '--package=package1')
    ]


class FilterAddTest(CLIActionTestCase):
    ORG = 'org'
    NAME = 'filter'
    FILTER1 = "filter1"
    FILTER2 = "filter2"
    FILTER3 = "filter3"

    OPTIONS = {
        'org':ORG,
        'name':NAME,
        'package_id': FILTER1
    }

    def setUp(self):
        self.set_action(AddPackage())
        self.set_module(katello.client.core.filters)
        self.mock_printer()
        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'info', {'package_list':[self.FILTER2, self.FILTER3]})
        self.mock(self.action.api, 'update_packages')

    def tearDown(self):
        self.restore_mocks()

    def test_it_calls_filter_info_api(self):
        self.run_action()
        self.action.api.info.assert_called_once_with(self.ORG, self.NAME)

    def test_it_calls_filter_update_api(self):
        self.run_action()
        self.action.api.update_packages.assert_called_once_with(self.ORG, self.NAME, [self.FILTER2, self.FILTER3, self.FILTER1])
