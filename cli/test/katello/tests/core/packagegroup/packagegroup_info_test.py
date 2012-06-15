import unittest
from mock import Mock
import urlparse
from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase
from copy import deepcopy

from katello.tests.core.packagegroup import packagegroup_data
from katello.tests.core.repo import repo_data

import katello.client.core.packagegroup
from katello.client.core.packagegroup import Info

class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = Info()

    disallowed_options = [
        (),
        ('--repo_id=123', ),
        ('--id=123', ),
    ]

    allowed_options = [
        ('--repo_id=123','--id=123')
    ]


class PackageGroupInfoTest(CLIActionTestCase):

    REPO = repo_data.REPOS[0]
    PACKAGE_GROUP = packagegroup_data.PACKAGE_GROUPS[0]

    OPTIONS = {
        'repo_id': REPO['id'],
        'id': PACKAGE_GROUP['id'],
    }

    def setUp(self):
        self.set_action(Info())
        self.set_module(katello.client.core.packagegroup)

        self.mock_options(self.OPTIONS)
        self.mock_printer()

        self.mock(self.action.api, 'packagegroup_by_id', self.PACKAGE_GROUP)

    def tearDown(self):
        self.restore_mocks()

    def test_it_finds_package_group_by_id(self):
        self.mock_options(self.OPTIONS)
        self.run_action()
        self.action.api.packagegroup_by_id.assert_called_once_with(self.REPO['id'], self.PACKAGE_GROUP['id'])

    def test_it_prints_package_groups(self):
        self.run_action()
        printed_group = deepcopy(self.PACKAGE_GROUP)
        printed_group["conditional_package_names"] = []
        self.action.printer.print_item.assert_called_once_with(printed_group)
