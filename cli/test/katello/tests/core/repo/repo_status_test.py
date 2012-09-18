import unittest
from mock import Mock
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase
from katello.tests.core.repo import repo_data

import katello.client.core.repo
from katello.client.core.repo import Status
from katello.client.api.utils import ApiDataError


class RequiredCLIOptionsTests(CLIOptionTestCase):
    #repo is defined by either (org, product, repo_name, env name) or repo_id
    action = Status()

    disallowed_options = [
        ('--name=repo1', '--product=product1'),
        ('--org=ACME', '--name=repo1'),
        ('--org=ACME', '--product=product1'),
        (),
    ]

    allowed_options = [
        ('--org=ACME', '--name=repo1', '--product=product1'),
        ('--id=repo_id1', ),
    ]



class RepoStatusTest(CLIActionTestCase):

    ORG_NAME = "org_1"
    PROD_NAME = "product_1"
    REPO = repo_data.REPOS[0]
    ENV_NAME = "env_1"

    OPTIONS_WITH_ID = {
        'id': REPO['id'],
    }

    OPTIONS_WITH_NAME = {
        'name': REPO['name'],
        'product': PROD_NAME,
        'org': ORG_NAME,
        'environment': ENV_NAME,
    }

    repo = None

    def setUp(self):
        self.set_action(Status())
        self.set_module(katello.client.core.repo)
        self.mock_printer()

        self.mock_options(self.OPTIONS_WITH_NAME)

        self.mock(self.action.api, 'repo', self.REPO)
        self.mock(self.action.api, 'last_sync_status', repo_data.SYNC_RESULT_WITHOUT_ERROR)

        self.repo = self.mock(self.module, 'get_repo', self.REPO).return_value

    def tearDown(self):
        self.restore_mocks()

    def test_finds_repo_by_id(self):
        self.mock_options(self.OPTIONS_WITH_ID)
        self.run_action()
        self.action.api.repo.assert_called_once_with(self.REPO['id'])

    def test_finds_repo_by_name(self):
        self.mock_options(self.OPTIONS_WITH_NAME)
        self.run_action()
        self.module.get_repo.assert_called_once_with(self.ORG_NAME, self.PROD_NAME, self.REPO['name'], self.ENV_NAME, False)

    def test_returns_with_error_when_no_repo_found(self):
        self.mock_options(self.OPTIONS_WITH_NAME)
        self.mock(self.module, 'get_repo').side_effect = ApiDataError()
        self.run_action(os.EX_DATAERR)

    def test_it_calls_last_sync_status_api(self):
        self.run_action()
        self.action.api.last_sync_status.assert_called_once_with(self.REPO['id'])

    def test_it_does_not_set_progress_for_not_running_sync(self):
        self.run_action()
        self.assertRaises(KeyError, lambda: self.repo['progress'] )

    def test_it_sets_progress_for_running_sync(self):
        self.mock(self.action.api, 'last_sync_status', repo_data.SYNC_RUNNING_RESULT)
        self.run_action()
        self.assertTrue(isinstance(self.repo['progress'], str))
