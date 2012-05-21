import unittest
from mock import Mock
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.filters
from katello.client.core.filters import Info

class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = Info()

    disallowed_options = [
        ('--name=filter1', ),
        ('--org=ACME', )
    ]

    allowed_options = [
        ('--org=ACME', '--name=filter1')
    ]


class FilterAddTest(CLIActionTestCase):

    ORG = 'org'
    FILTER = 'filter'
    OPTIONS = {
        'org':ORG,
        'name':FILTER
    }

    def setUp(self):
        self.set_action(Info())
        self.set_module(katello.client.core.filters)
        self.mock_printer()
        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'info', {'package_list':[]})

    def tearDown(self):
        self.restore_mocks()

    def test_it_calls_filter_info_api(self):
        self.run_action()
        self.action.api.info.assert_called_once_with(self.ORG, self.FILTER)

    def test_package_list_as_string(self):
        self.assertEqual("filter1, filter2, filter3", self.action.package_list_as_string(["filter1", "filter2", "filter3"]))
