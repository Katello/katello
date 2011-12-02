import unittest
from mock import Mock
import os

from cli_test_utils import CLIActionTestCase
import test_data

import katello.client.core.provider
from katello.client.core.provider import CancelSync



class ProviderCancelSyncTest(CLIActionTestCase):

    ORG = test_data.ORGS[0]
    PROV = test_data.PROVIDERS[2]

    OPTIONS = {
        'org': ORG['name'],
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
        self.action.run()
        self.module.get_provider.assert_called_once_with(self.ORG['name'], self.PROV['name'])

    def test_it_returns_with_error_when_no_provider_found(self):
        self.module.get_provider.return_value =  None
        self.assertEqual(self.action.run(), os.EX_DATAERR)

    def test_it_calls_cancel_sync_api(self):
        self.action.run()
        self.action.api.cancel_sync.assert_called_once_with(self.PROV['id'])

    def test_returns_ok(self):
        self.assertEqual(self.action.run(), os.EX_OK)
