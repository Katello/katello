import unittest
from mock import Mock
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase,\
        CLIActionTestCase

from katello.tests.core.organization import organization_data
from katello.tests.core.content_view_definition import content_view_definition_data
from katello.tests.core.repo import repo_data
from katello.tests.core.product import product_data

import katello.client.core.content_view_definition
from katello.client.core.content_view_definition import AddRemoveRepo
from katello.client.api.utils import ApiDataError


class RequiredCLIOptionsTest(object):

    disallowed_options = [
        ('--org=ACME', '--label=def1', '--repo=repo1'),
        ('--org=ACME', '--name=def1', '--repo=repo1', '--product=photoshop'),
        ('--org=ACME', '--label=def1', '--product=photoshop'),
        ('--label=def1', '--repo=repo1', '--product=photoshop')
    ]

    allowed_options = [
        ('--org=ACME', '--label=def1', '--repo=repo1', '--product=photoshop')
    ]


class AddRequiredCLIOptionsTest(RequiredCLIOptionsTest, CLIOptionTestCase):
    action = AddRemoveRepo(True)

class RemoveRequiredCLIOptionsTest(RequiredCLIOptionsTest, CLIOptionTestCase):
    action = AddRemoveRepo(False)


class ContentDefinitionAddRemoveRepoTest(object):

    ORG = organization_data.ORGS[0]
    DEF = content_view_definition_data.DEFS[0]
    REPOS = repo_data.REPOS
    REPO = REPOS[0]
    PRODUCT = product_data.PRODUCTS[0]

    OPTIONS = {
        'org': ORG['name'],
        'label': DEF['label'],
        'repo': REPO['name'],
        'product': PRODUCT['label']
    }

    addition = True

    def setUp(self):
        self.set_action(AddRemoveRepo(self.addition))
        self.set_module(katello.client.core.content_view_definition)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.module, 'get_cv_definition', self.DEF)
        self.mock(self.module, 'get_repo', self.REPO)
        self.mock(self.action.api, 'repos', self.REPOS)
        self.mock(self.action.api, 'update_repos')

    def test_it_returns_with_error_if_no_def_was_found(self):
        self.mock(self.module, 'get_cv_definition').side_effect = ApiDataError()
        self.run_action(os.EX_DATAERR)

    def test_it_returns_with_error_if_view_was_not_found(self):
        self.mock(self.module, 'get_repo').side_effect = ApiDataError()
        self.run_action(os.EX_DATAERR)

    def test_it_retrieves_all_definition_repos(self):
        self.run_action()
        self.action.api.repos.assert_called_once_with(self.DEF['id'])
        self.action.get_repo.assert_called_once_with(self.ORG['name'],
                self.REPO['name'], prodLabel=self.PRODUCT['label'])


class ContentDefinitionAddRepoTest(ContentDefinitionAddRemoveViewTest, CLIActionTestCase):
    addition = True

    def test_it_calls_update_api(self):
        repos = [r['id'] for r in self.REPOS + [self.REPO]]
        self.run_action()
        self.action.api.update_repos.assert_called_once_with(self.DEF['id'],
                repos)


class ContentDefinitionRemoveViewTest(ContentDefinitionAddRemoveViewTest, CLIActionTestCase):
    addition = False

    def test_it_calls_update_api(self):
        repos = [r['id'] for r in self.REPOS if r['name'] != self.REPO['name']]
        self.run_action()
        self.action.api.update_repos.assert_called_once_with(self.DEF['id'],
                repos)
