import unittest
from mock import Mock
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.repo
from katello.client.core.repo import Status
from katello.client.core.utils import SystemExitRequest



class RequiredCLIOptionsTests(CLIOptionTestCase):
    #repo is defined by either (org, product, repo_name, env name) or repo_id
    def setUp(self):
        self.set_action(Status())
        self.mock_options()

    def test_missing_org_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['status', '--name=repo1', '--product=product1'])

    def test_missing_product_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['status', '--org=ACME', '--name=repo1', ])

    def test_missing_repo_name_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['status', '--org=ACME', '--product=product1'])

    def test_missing_repo_id_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['status'])

    def test_no_error_if_required_options_provided(self):
        self.action.process_options(['status', '--org=ACME', '--name=repo1', '--product=product1'])
        self.assertEqual(len(self.action.optErrors), 0)

    def test_no_error_if_required_repo_id_provided(self):
        self.action.process_options(['status', '--id=repo_id1'])
        self.assertEqual(len(self.action.optErrors), 0)


class RepoStatusTest(CLIActionTestCase):

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
        'env': ENV['name'],
    }

    repo = None

    def setUp(self):
        self.set_action(Status())
        self.set_module(katello.client.core.repo)
        self.mock_printer()

        self.mock_options(self.OPTIONS_WITH_NAME)

        self.mock(self.action.api, 'repo', self.REPO)
        self.mock(self.action.api, 'last_sync_status', test_data.SYNC_RESULT_WITHOUT_ERROR)

        self.repo = self.mock(self.module, 'get_repo', self.REPO).return_value

    def tearDown(self):
        self.restore_mocks()

    def test_finds_repo_by_id(self):
        self.mock_options(self.OPTIONS_WITH_ID)
        self.action.run()
        self.action.api.repo.assert_called_once_with(self.REPO['id'])

    def test_finds_repo_by_name(self):
        self.mock_options(self.OPTIONS_WITH_NAME)
        self.action.run()
        self.module.get_repo.assert_called_once_with(self.ORG['name'], self.PROD['name'], self.REPO['name'], self.ENV['name'], False)

    def test_returns_with_error_when_no_repo_found(self):
        self.mock_options(self.OPTIONS_WITH_NAME)
        self.module.get_repo.return_value =  None
        ex = self.assertRaisesException(SystemExitRequest, self.action.run)
        self.assertEqual(ex.args[0], os.EX_DATAERR)

    def test_it_calls_last_sync_status_api(self):
        self.action.run()
        self.action.api.last_sync_status.assert_called_once_with(self.REPO['id'])

    def test_it_does_not_set_progress_for_not_running_sync(self):
        self.action.run()
        self.assertRaises(KeyError, lambda: self.repo['progress'] )

    def test_it_sets_progress_for_running_sync(self):
        self.mock(self.action.api, 'last_sync_status', test_data.SYNC_RUNNING_RESULT)
        self.action.run()
        self.assertTrue(isinstance(self.repo['progress'], str))
