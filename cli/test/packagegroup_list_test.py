import unittest
from mock import Mock
import urlparse
from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.packagegroup
from katello.client.core.packagegroup import List

class RequiredCLIOptionsTests(CLIOptionTestCase):
    def setUp(self):
        self.set_action(List())
        self.mock_options()

    def test_missing_repoid_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['list'])

    def test_no_error_if_required_options_provided(self):
        self.action.process_options(['list', '--repo_id=123'])
        self.assertEqual(len(self.action.optErrors), 0)


class PackageGroupListTest(CLIActionTestCase):

    REPO = test_data.REPOS[0]

    OPTIONS = {
        'repo_id': REPO['id'],
    }

    def setUp(self):
        self.set_action(List())
        self.set_module(katello.client.core.packagegroup)

        self.mock_options(self.OPTIONS)
        self.mock_printer()

        self.mock(self.action.api, 'packagegroups', test_data.PACKAGE_GROUPS)

    def tearDown(self):
        self.restore_mocks()

    def test_it_finds_package_groups_by_repo(self):
        self.mock_options(self.OPTIONS)
        self.run_action()
        self.action.api.packagegroups.assert_called_once_with(self.REPO['id'])

    def test_it_prints_package_groups(self):
        self.run_action()
        self.action.printer.print_items.assert_called_once_with(test_data.PACKAGE_GROUPS)
