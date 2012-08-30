import unittest
from mock import Mock
import os

from katello.tests.core.action_test_utils import CLIActionTestCase
from katello.tests.core.provider import provider_data
from katello.tests.core.repo import repo_data

import katello.client.core.provider
from katello.client.core.provider import Status
from katello.client.api.utils import ApiDataError


class ProviderStatusTest(CLIActionTestCase):

    ORG_NAME = "org_1"
    PROV = provider_data.PROVIDERS[2]

    OPTIONS = {
        'org': ORG_NAME,
        'name': PROV['name']
    }

    provider = None

    def setUp(self):
        self.set_action(Status())
        self.set_module(katello.client.core.provider)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'last_sync_status', repo_data.SYNC_RESULT_WITHOUT_ERROR)

        self.provider = self.mock(self.module, 'get_provider', self.PROV).return_value

    def tearDown(self):
        self.restore_mocks()

    def test_it_finds_the_provider(self):
        self.run_action()
        self.module.get_provider.assert_called_once_with(self.ORG_NAME, self.PROV['name'])

    def test_it_returns_with_error_when_no_provider_found(self):
        self.mock(self.module, 'get_provider').side_effect = ApiDataError()
        self.run_action(os.EX_DATAERR)

    def test_it_calls_last_sync_status_api(self):
        self.run_action()
        self.action.api.last_sync_status.assert_called_once_with(self.PROV['id'])

    def test_it_does_not_set_progress_for_not_running_sync(self):
        self.run_action()
        self.assertRaises(KeyError, lambda: self.provider['progress'] )

    def test_it_sets_progress_for_running_sync(self):
        self.mock(self.action.api, 'last_sync_status', repo_data.SYNC_RUNNING_RESULT)
        self.run_action()
        self.assertTrue(isinstance(self.provider['progress'], unicode))
