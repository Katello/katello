import unittest
from mock import Mock
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase
from katello.tests.core.repo import repo_data
from katello.tests.core.filter import filter_data

import katello.client.core.repo
from katello.client.core.repo import AddRemoveFilter
from katello.client.api.utils import ApiDataError


class RequiredCLIOptionsTest(object):

    disallowed_options = [
        ('--name=repo1', '--product=product1', '--filter=f1'),
        ('--org=ACME', '--name=repo1', '--filter=f1'),
        ('--org=ACME', '--product=product1', '--filter=f1'),
        ('--org=ACME', '--product=product1', '--name=repo1'),
        ('--filter=f1'),
    ]

    allowed_options = [
        ('--org=ACME', '--name=repo1', '--product=product1', '--filter=f1'),
        ('--id=repo_id1', '--filter=f1')
    ]


class AddRequiredCLIOptionsTest(RequiredCLIOptionsTest, CLIOptionTestCase):
    #repo is defined by either (org, product, repo_name, env name) or repo_id
    action = AddRemoveFilter(True)


class RemoveRequiredCLIOptionsTest(RequiredCLIOptionsTest, CLIOptionTestCase):
    #repo is defined by either (org, product, repo_name, env name) or repo_id
    action = AddRemoveFilter(False)


class RepoAddRemoveFilterTest(object):

    ORG_NAME = 'org_1'
    PROD_NAME = 'product_1'
    REPO = repo_data.REPOS[0]
    FILTERS = filter_data.FILTERS
    FILTER = FILTERS[0]

    OPTIONS_WITH_ID = {
        'id': REPO['id'],
        'filter': FILTERS[0]['name']
    }

    OPTIONS_WITH_NAME = {
        'name': REPO['name'],
        'product': PROD_NAME,
        'org': ORG_NAME,
        'filter': FILTERS[0]['name']
    }

    addition = True


    def setUp(self):
        self.set_action(AddRemoveFilter(self.addition))
        self.set_module(katello.client.core.repo)
        self.mock_printer()

        self.mock_options(self.OPTIONS_WITH_NAME)

        self.mock(self.action.api, 'repo', self.REPO)
        self.mock(self.action.api, 'filters', self.FILTERS)
        self.mock(self.action.api, 'update_filters')

        self.mock(self.module, 'get_repo', self.REPO)
        self.mock(self.module, 'get_filter', self.FILTER)


    def test_finds_repo_by_id(self):
        self.mock_options(self.OPTIONS_WITH_ID)
        self.action.run()
        self.action.api.repo.assert_called_once_with(self.REPO['id'])

    def test_finds_repo_by_name(self):
        self.mock_options(self.OPTIONS_WITH_NAME)
        self.action.run()
        self.module.get_repo.assert_called_once_with(self.ORG_NAME, self.PROD_NAME, self.REPO['name'], None, False)

    def test_returns_error_when_no_repo_found(self):
        self.mock_options(self.OPTIONS_WITH_NAME)
        self.mock(self.module, 'get_repo').side_effect = ApiDataError()
        self.run_action(os.EX_DATAERR)

    def test_returns_error_when_no_filter_found(self):
        self.mock_options(self.OPTIONS_WITH_NAME)
        self.mock(self.module, 'get_filter').side_effect = ApiDataError()
        self.run_action(os.EX_DATAERR)

    def test_it_calls_filters_api(self):
        self.action.run()
        self.action.api.filters.assert_called_once_with(self.REPO['id'])


class RepoAddFilterTest(RepoAddRemoveFilterTest, CLIActionTestCase):
    addition = True

    def test_it_calls_update_api(self):
        filters = [f['name'] for f in self.FILTERS + [self.FILTER]]
        self.action.run()
        self.action.api.update_filters.assert_called_once_with(self.REPO['id'], filters)


class RepoRemoveFilterTest(RepoAddRemoveFilterTest, CLIActionTestCase):
    addition = False

    def test_it_calls_update_api(self):
        filters = [f['name'] for f in self.FILTERS if f['name'] != self.FILTER['name']]
        self.action.run()
        self.action.api.update_filters.assert_called_once_with(self.REPO['id'], filters)
