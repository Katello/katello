import unittest
from mock import Mock
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase
from katello.tests.core.repo import repo_data

import katello.client.core.repo
from katello.client.core.repo import ListFilters
from katello.client.api.utils import ApiDataError


class RequiredCLIOptionsTests(CLIOptionTestCase):
    #repo is defined by either (org, product, repo_name, env name) or repo_id
    action = ListFilters()

    disallowed_options = [
        ('--name=repo1', '--product=product1'),
        ('--org=ACME', '--name=repo1'),
        ('--org=ACME', '--product=product1'),
    ]

    allowed_options = [
        ('--org=ACME', '--name=repo1', '--product=product1'),
        ('--id=repo_id1', ),
    ]



class RepoListFiltersTest(CLIActionTestCase):

    ORG_NAME = "org_1"
    PROD_NAME = "product_1"
    REPO = repo_data.REPOS[0]

    OPTIONS_WITH_ID = {
        'id': REPO['id'],
        'inherit': False
    }

    OPTIONS_WITH_NAME = {
        'name': REPO['name'],
        'product': PROD_NAME,
        'org': ORG_NAME,
        'inherit': False
    }

    repo = None

    def setUp(self):
        self.set_action(ListFilters())
        self.set_module(katello.client.core.repo)
        self.mock_printer()

        self.mock_options(self.OPTIONS_WITH_NAME)

        self.mock(self.action.api, 'repo', self.REPO)
        self.mock(self.action.api, 'filters', [])

        self.repo = self.mock(self.module, 'get_repo', self.REPO).return_value


    def test_finds_repo_by_id(self):
        self.mock_options(self.OPTIONS_WITH_ID)
        self.run_action()
        self.action.api.repo.assert_called_once_with(self.REPO['id'])

    def test_finds_repo_by_name(self):
        self.mock_options(self.OPTIONS_WITH_NAME)
        self.run_action()
        self.module.get_repo.assert_called_once_with(self.ORG_NAME, self.PROD_NAME, self.REPO['name'], None, False)

    def test_returns_with_error_when_no_repo_found(self):
        self.mock_options(self.OPTIONS_WITH_NAME)
        self.mock(self.module, 'get_repo').side_effect = ApiDataError()
        self.run_action(os.EX_DATAERR)

    def test_it_calls_filters_api(self):
        self.run_action()
        self.action.api.filters.assert_called_once_with(self.REPO['id'], False)
