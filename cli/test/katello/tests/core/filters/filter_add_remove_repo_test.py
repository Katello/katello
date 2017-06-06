import unittest
from mock import Mock
import os
from katello.tests.core.action_test_utils import CLIOptionTestCase,\
        CLIActionTestCase
from katello.tests.core.content_view_definition import content_view_definition_data
from katello.tests.core.organization import organization_data
from katello.tests.core.repo import repo_data
from katello.tests.core.product import product_data
import katello.client.core.filter
from katello.client.core.filter import AddRemoveRepo
from katello.client.api.utils import ApiDataError

class RequiredCLIOptionsTest(object):

    disallowed_options = [
        ('--org=ACME', '--name=def1', '--repo=repo1', "--definition=foo"),
        ('--org=ACME', '--repo=repo1', '--product=photoshop', "--definition=foo"),
        ('--org=ACME', '--name=def1', '--product=photoshop', "--definition=foo"),
        ('--namel=def1', '--repo=repo1', '--product=photoshop', "--definition=foo")
    ]

    allowed_options = [
        ('--org=ACME', '--name=def1', '--repo=repo1', '--product=photoshop', "--definition=foo")
    ]


class AddRequiredCLIOptionsTest(RequiredCLIOptionsTest, CLIOptionTestCase):
    action = AddRemoveRepo(True)

class RemoveRequiredCLIOptionsTest(RequiredCLIOptionsTest, CLIOptionTestCase):
    action = AddRemoveRepo(False)


class FilterAddRemoveRepoTest(object):
    ORG = organization_data.ORGS[0]
    REPOS = repo_data.REPOS
    REPO = REPOS[0]
    PRODUCT = product_data.PRODUCTS[0]
    DEFINITION = content_view_definition_data.DEFS[0]
    FILTER = content_view_definition_data.FILTERS[0]

    OPTIONS = {
        'org': ORG['name'],
        'label': DEFINITION['label'],
        'repo': REPO['name'],
        'product': PRODUCT['label'],
        'definition': DEFINITION["name"],

    }

    addition = True

    def setUp(self):
        self.set_action(AddRemoveRepo(self.addition))
        self.set_module(katello.client.core.filter)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.module, 'get_cv_definition', self.DEFINITION)
        self.mock(self.module, 'get_filter', self.FILTER)
        self.mock(self.module, 'get_repo', self.REPO)
        self.mock(self.action.api, 'repos', self.REPOS)
        self.mock(self.action.api, 'update_repos')

    def test_it_returns_with_error_if_no_def_was_found(self):
        self.mock(self.module, 'get_cv_definition').side_effect = ApiDataError()
        self.run_action(os.EX_DATAERR)

    def test_it_returns_with_error_if_no_filter_was_found(self):
        self.mock(self.module, 'get_filter').side_effect = ApiDataError()
        self.run_action(os.EX_DATAERR)

    def test_it_returns_with_error_if_repo_was_not_found(self):
        self.mock(self.module, 'get_repo').side_effect = ApiDataError()
        self.run_action(os.EX_DATAERR)

    def test_it_retrieves_all_definition_repos(self):
        self.run_action()
        self.action.api.repos.assert_called_once_with(self.FILTER['id'],
                                 self.DEFINITION['id'], self.ORG['name'])
        self.module.get_repo.assert_called_once_with(self.ORG['name'],
                self.REPO['name'], self.PRODUCT['label'], None, None)

class FilterAddRepoTest(FilterAddRemoveRepoTest, CLIActionTestCase):
    addition = True
    def test_it_calls_update_api(self):
        repos = [r['id'] for r in self.REPOS + [self.REPO]]
        self.run_action()
        self.action.api.update_repos.assert_called_once_with(self.FILTER['id'],
             self.DEFINITION['id'], self.ORG["name"], repos)

class FilterRemoveRepoTest(FilterAddRemoveRepoTest, CLIActionTestCase):
    addition = False

    def test_it_calls_update_api(self):
        repos = [r['id'] for r in self.REPOS if r['name'] != self.REPO['name']]
        self.run_action()
        self.action.api.update_repos.assert_called_once_with(self.FILTER['id'],
             self.DEFINITION['id'], self.ORG['name'], repos)