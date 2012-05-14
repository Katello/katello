import unittest
import os
from mock import Mock
from cli_test_utils import CLIOptionTestCase, CLIActionTestCase

import katello.client.core.repo
from katello.client.core.repo import Sync
from katello.client.api.utils import ApiDataError

try:
    import json
except ImportError:
    import simplejson as json

class RequiredCLIOptionsTests(CLIOptionTestCase):
    #repo is defined by either (org, product, repo_name) or repo_id
    def setUp(self):
        self.set_action(Sync())
        self.mock_options()

    def test_missing_org_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['synchronize', '--name=repo1', '--product=product1'])

    def test_missing_product_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['synchronize', '--org=ACME', '--name=repo1', ])

    def test_missing_repo_name_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['synchronize', '--org=ACME', '--product=product1'])

    def test_missing_repo_id_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['synchronize'])

    def test_no_error_if_required_options_provided(self):
        self.action.process_options(['synchronize', '--org=ACME', '--name=repo1', '--product=product1'])
        self.assertEqual(len(self.action.optErrors), 0)

    def test_no_error_if_required_repo_id_provided(self):
        self.action.process_options(['synchronize', '--id=repo_id1'])
        self.assertEqual(len(self.action.optErrors), 0)



class SynchronizeTestWithRepoId(CLIActionTestCase):
    REPO_ID = 'repo_123'
    REPO_NAME = 'repo_name'

    REPO = {
        'id': REPO_ID,
        'name': REPO_NAME
    }

    OPTIONS_WITH_ID = {
        'id': REPO_ID,
    }

    OPTIONS_WITH_NAME = {
        'name': REPO_NAME,
        'product': 'product_1',
        'org': 'ACME'
    }

    SYNC_RESULT_WITHOUT_ERROR = [{'state':'finished'}]
    SYNC_RESULT_WITH_ERROR = [{'state':'error', 'result':{'errors':["some error"]}, 'progress': {'error_details': []} }]

    def setUp(self):
        self.set_action(Sync())
        self.set_module(katello.client.core.repo)

        self.mock_options(self.OPTIONS_WITH_ID)

        self.mock(self.action.api, 'repo', self.REPO)
        self.mock(self.action.api, 'sync', self.SYNC_RESULT_WITHOUT_ERROR)

        self.mock(self.module, 'get_repo', self.REPO)
        self.mock(self.module, 'run_async_task_with_status')

    def tearDown(self):
        self.restore_mocks()


    def test_finds_repo_by_id(self):
        self.mock_options(self.OPTIONS_WITH_ID)
        self.run_action()
        self.action.api.repo.assert_called_once_with(self.REPO_ID)

    def test_finds_repo_by_name(self):
        self.mock_options(self.OPTIONS_WITH_NAME)
        self.run_action()
        self.module.get_repo.assert_called_once()

    def test_returns_with_error_when_no_repo_found(self):
        self.mock_options(self.OPTIONS_WITH_NAME)
        self.mock(self.module, 'get_repo').side_effect = ApiDataError()
        self.run_action(os.EX_DATAERR)


    def test_calls_sync_api(self):
        self.run_action()
        self.action.api.sync.assert_called_once_with(self.REPO_ID)

    def test_waits_for_sync(self):
        self.run_action()
        self.module.run_async_task_with_status.assert_called_once()

    def test_returns_ok_when_sync_was_successful(self):
        self.run_action(os.EX_OK)

    def test_returns_error_if_sync_failed(self):
        self.mock(self.action.api, 'sync', self.SYNC_RESULT_WITH_ERROR)
        self.run_action(os.EX_DATAERR)
