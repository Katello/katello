import unittest
from mock import Mock
import os

#from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import cli_test_utils
import test_data

import katello.client.core.filters
from katello.client.core.filters import List



class RequiredCLIOptionsTests(cli_test_utils.CLIOptionTestCase):

    action = List()

    disallowed_options = [
        ('--name=product_1', )
    ]

    allowed_options = [
        ('--org=ACME', )
    ]

class FilterListTest(cli_test_utils.CLIActionTestCase):

    ORG = 'some_org'
    OPTIONS = {'org':ORG}

    def setUp(self):
        self.set_action(List())
        self.set_module(katello.client.core.filters)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'filters', [])

    def tearDown(self):
        self.restore_mocks()

    def test_it_uses_filter_list_api(self):
        self.run_action()
        self.action.api.filters.assert_called_once_with(self.ORG)
