import unittest
from mock import Mock
import urlparse
from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.packagegroup
from katello.client.core.packagegroup import Info

class RequiredCLIOptionsTests(CLIOptionTestCase):
    def setUp(self):
        self.set_action(Info())
        self.mock_options()

    def test_missing_id_and_repoid_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['info'])

    def test_missing_id_generates_error(self):
        self.assertRaises(Exception, self.action.process_options,
                          ['info', '--repoid=123'])

    def test_missing_repoid_generates_error(self):
        self.assertRaises(Exception, self.action.process_options,
                          ['info', '--id=123'])

    def test_no_error_if_required_options_provided(self):
        self.action.process_options(['info', '--repoid=123','--id=123'])
        self.assertEqual(len(self.action.optErrors), 0)


class PackageGroupInfoTest(CLIActionTestCase):

    REPO = test_data.REPOS[0]
    PACKAGE_GROUP = test_data.PACKAGE_GROUPS["123"]

    OPTIONS = {
        'repoid': REPO['id'],
        'id': PACKAGE_GROUP['id'],
    }

    def setUp(self):
        self.set_action(Info())
        self.set_module(katello.client.core.packagegroup)

        self.mock_options(self.OPTIONS)
        self.mock_printer()

        self.mock(self.action.api, 'packagegroups', test_data.PACKAGE_GROUPS)

    def tearDown(self):
        self.restore_mocks()

    def test_it_finds_package_groups_by_repo(self):
        self.mock_options(self.OPTIONS)
        self.action.run()
        self.action.api.packagegroups.assert_called_once_with(self.REPO['id'])

    def test_it_prints_package_groups(self):
        self.action.run()
        self.action.printer.printItem.assert_called_once_with(self.PACKAGE_GROUP)
