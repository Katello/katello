import unittest
from mock import Mock
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.filters
from katello.client.core.filters import RemovePackage

class RequiredCLIOptionsTests(CLIOptionTestCase):

    def setUp(self):
        self.set_action(RemovePackage())
        self.mock_options()

    def test_missing_org_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['remove_package', '--name=filter1', '--package=package1'])

    def test_missing_name_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['remove_package', '--org=ACME', '--package=package1'])

    def test_missing_package_id_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['remove_package', '--org=ACME', '--name=filter1'])

    def test_no_error_if_org_and_name_provided(self):
        self.action.process_options(['remove_package', '--org=ACME', '--name=filter1', '--package=package1'])
        self.assertEqual(len(self.action.optErrors), 0)


class FilterAddTest(CLIActionTestCase):
    ORG = 'org'
    NAME = 'filter'
    FILTER1 = "filter1"
    FILTER2 = "filter2"
    FILTER3 = "filter3"

    OPTIONS = {
        'org':ORG,
        'name':NAME,
        'package_id': FILTER2
    }

    def setUp(self):
        self.set_action(RemovePackage())
        self.set_module(katello.client.core.filters)
        self.mock_printer()
        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'info', {'package_list':[self.FILTER2, self.FILTER3]})
        self.mock(self.action.api, 'update_packages')

    def tearDown(self):
        self.restore_mocks()

    def test_it_calls_filter_info_api(self):
        self.action.run()
        self.action.api.info.assert_called_once_with(self.ORG, self.NAME)

    def test_it_calls_filter_update_api(self):
        self.action.run()
        self.action.api.update_packages.assert_called_once_with(self.ORG, self.NAME, [self.FILTER3])
