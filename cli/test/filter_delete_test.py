import unittest
from mock import Mock
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.filters
from katello.client.core.filters import Delete

class RequiredCLIOptionsTests(CLIOptionTestCase):

    def setUp(self):
        self.set_action(Delete())
        self.mock_options()

    def test_missing_org_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['delete', '--name=filter1'])

    def test_missing_name_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['delete', '--org=ACME'])

    def test_no_error_if_org_and_name_provided(self):
        self.action.process_options(['delete', '--org=ACME', '--name=filter1'])
        self.assertEqual(len(self.action.optErrors), 0)


class FilterDeleteTest(CLIActionTestCase):

    ORG = 'org'
    FILTER = 'filter'

    OPTIONS = {
        'org':ORG,
        'name':FILTER
    }

    def setUp(self):
        self.set_action(Delete())
        self.set_module(katello.client.core.filters)
        self.mock_printer()
        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'delete')

    def tearDown(self):
        self.restore_mocks()

    def test_it_uses_filter_delete_api(self):
        self.run_action()
        self.action.api.delete.assert_called_once_with(self.ORG, self.FILTER)
