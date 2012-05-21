import unittest
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.repo
from katello.client.core.repo import Delete
from katello.client.core.utils import SystemExitRequest
from katello.client.api.utils import ApiDataError

class RequiredCLIOptionsTests(CLIOptionTestCase):
    #repo is defined by either (org, product, repo_name) or repo_id

    action = Delete()

    disallowed_options = [
        ('--name=repo1', '--product=product1'),
        ('--org=ACME', '--name=repo1'),
        (),
    ]

    allowed_options = [
        ('--org=ACME', '--name=repo1', '--product=product1'),
        ('--id=repo_id1', )
    ]


class DeleteTest(CLIActionTestCase):

    ORG = test_data.ORGS[0]
    PROD = test_data.PRODUCTS[0]
    REPO = test_data.REPOS[0]
    ENV = test_data.ENVS[0]

    OPTIONS_WITH_ID = {
        'id': REPO['id'],
    }

    OPTIONS_WITH_NAME = {
        'name': REPO['name'],
        'product': PROD['name'],
        'org': ORG['name'],
    }

    def setUp(self):
        self.set_action(Delete())
        self.set_module(katello.client.core.repo)

        self.mock_options(self.OPTIONS_WITH_ID)

        self.mock(self.module, 'get_repo', self.REPO)

        self.mock(self.action.api, 'repo', self.REPO)
        self.mock(self.action.api, 'delete')

    def test_finds_repo_by_id(self):
        self.mock_options(self.OPTIONS_WITH_ID)
        self.run_action()
        self.action.api.repo.assert_called_once_with(self.REPO['id'])

    def test_finds_repo_by_name(self):
        self.mock_options(self.OPTIONS_WITH_NAME)
        self.run_action()
        self.module.get_repo.assert_called_once_with(self.ORG['name'], self.PROD['name'], self.REPO['name'], None, False)

    def test_returns_with_error_when_no_repo_found(self):
        self.mock_options(self.OPTIONS_WITH_NAME)
        self.mock(self.module, 'get_repo').side_effect = ApiDataError()
        self.run_action(os.EX_DATAERR)


    def test_it_calls_delete_api(self):
        self.run_action()
        self.action.api.delete.assert_called_once_with(self.REPO['id'])

    def test_it_returns_status_ok(self):
        self.run_action()
        self.run_action(os.EX_OK)
