import unittest
from mock import Mock
import urlparse
from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase

from katello.tests.core.packagegroup import packagegroup_data
from katello.tests.core.repo import repo_data

import katello.client.core.packagegroup
from katello.client.core.packagegroup import CategoryList

class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = CategoryList()

    disallowed_options = [
        ()
    ]

    allowed_options = [
        ('--repo_id=123', )
    ]


class PackageGroupCategoryListTest(CLIActionTestCase):

    REPO = repo_data.REPOS[0]

    OPTIONS = {
        'repo_id': REPO['id'],
    }

    def setUp(self):
        self.set_action(CategoryList())
        self.set_module(katello.client.core.packagegroup)

        self.mock_options(self.OPTIONS)
        self.mock_printer()

        self.mock(self.action.api, 'packagegroupcategories',
                  packagegroup_data.PACKAGE_GROUP_CATEGORIES)

    def tearDown(self):
        self.restore_mocks()

    def test_it_finds_package_group_categories_by_repo(self):
        self.mock_options(self.OPTIONS)
        self.run_action()
        self.action.api.packagegroupcategories.assert_called_once_with(self.REPO['id'])

    def test_it_prints_package_groups(self):
        self.run_action()
        self.action.printer.print_items.assert_called_once_with(packagegroup_data.PACKAGE_GROUP_CATEGORIES)
