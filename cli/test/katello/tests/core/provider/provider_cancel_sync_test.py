import unittest
from mock import Mock
import os

from katello.tests.core.action_test_utils import CLIActionTestCase
from katello.tests.core.provider import provider_data

import katello.client.core.provider
from katello.client.core.provider import CancelSync
from katello.client.api.utils import ApiDataError


class ProviderCancelSyncTest(CLIActionTestCase):

    ORG_NAME = "org_1"
    PROV = provider_data.PROVIDERS[2]

    OPTIONS = {
        'org': ORG_NAME,
        'name': PROV['name']
    }

    provider = None

    def setUp(self):
        self.set_action(CancelSync())
        self.set_module(katello.client.core.provider)

        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'cancel_sync')

        self.provider = self.mock(self.module, 'get_provider', self.PROV).return_value


    def test_it_finds_the_provider(self):
        self.run_action()
        self.module.get_provider.assert_called_once_with(self.ORG_NAME, self.PROV['name'])

    def test_it_returns_with_error_when_no_provider_found(self):
        self.mock(self.module, 'get_provider').side_effect = ApiDataError()
        self.run_action(os.EX_DATAERR)

    def test_it_calls_cancel_sync_api(self):
        self.run_action()
        self.action.api.cancel_sync.assert_called_once_with(self.PROV['id'])

    def test_returns_ok(self):
        self.run_action(os.EX_OK)
