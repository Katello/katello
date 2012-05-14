import unittest
from mock import Mock
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.filters
from katello.client.core.filters import List



class RequiredCLIOptionsTests(CLIOptionTestCase):

    def setUp(self):
        self.set_action(List())
        self.mock_options()

    def test_missing_org_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['list', '--name=product_1'])

    def test_no_error_if_org_and_product_provided(self):
        self.action.process_options(['list', '--org=ACME'])
        self.assertEqual(len(self.action.optErrors), 0)


class FilterListTest(CLIActionTestCase):

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
