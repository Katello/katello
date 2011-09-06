import unittest
from mock import Mock
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.provider
from katello.client.core.provider import Status



class RequiredCLIOptionsTests(CLIOptionTestCase):
    
    def setUp(self):
        self.set_action(Status())
        self.mock_options()

    def test_missing_org_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['status', '--name=product_1'])

    def test_missing_product_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['status', '--org=ACME'])

    def test_no_error_if_org_and_product_provided(self):
        self.action.process_options(['status', '--org=ACME', '--name=product_1'])
        self.assertEqual(len(self.action.optErrors), 0)

        
class ProviderStatusTest(CLIActionTestCase):
    
    ORG = test_data.ORGS[0]
    PROV = test_data.PROVIDERS[2]
    
    OPTIONS = {
        'org': ORG['name'],
        'name': PROV['name']
    }
    
    provider = None
    
    def setUp(self):
        self.set_action(Status())
        self.set_module(katello.client.core.provider)
        self.mock_printer()
        
        self.mock_options(self.OPTIONS)
        
        self.mock(self.action.api, 'last_sync_status', test_data.SYNC_RESULT_WITHOUT_ERROR)
        
        self.provider = self.mock(self.module, 'get_provider', self.PROV).return_value
        
    def tearDown(self):
        self.restore_mocks()

    def test_it_finds_the_provider(self):
        self.action.run()
        self.module.get_provider.assert_called_once_with(self.ORG['name'], self.PROV['name'])
    
    def test_it_returns_with_error_when_no_provider_found(self):
        self.module.get_provider.return_value =  None
        self.action.run()
        self.assertEqual(self.action.run(), os.EX_DATAERR)
        
    def test_it_calls_last_sync_status_api(self):
        self.action.run()
        self.action.api.last_sync_status.assert_called_once_with(self.PROV['id'])

    def test_it_does_not_set_progress_for_not_running_sync(self):
        self.action.run()
        self.assertRaises(KeyError, lambda: self.provider['progress'] )

    def test_it_sets_progress_for_running_sync(self):
        self.mock(self.action.api, 'last_sync_status', test_data.SYNC_RUNNING_RESULT)
        self.action.run()
        self.assertTrue(isinstance(self.provider['progress'], str))

        

