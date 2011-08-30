import unittest
from mock import Mock
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.product
from katello.client.core.product import Sync



class RequiredCLIOptionsTests(CLIOptionTestCase):
    
    def setUp(self):
        self.set_action(Sync())
        self.mock_options()

    def test_missing_org_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['synchronize', '--name=product_1'])

    def test_missing_product_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['synchronize', '--org=ACME'])

    def test_no_error_if_org_and_product_provided(self):
        self.action.process_options(['list', '--org=ACME', '--name=product_1'])
        self.assertEqual(len(self.action.optErrors), 0)
        
class ProductSyncTest(CLIActionTestCase):
    
    ORG = test_data.ORGS[0]
    ENV = test_data.ENVS[0]
    PROV = test_data.PROVIDERS[2]
    PROD = test_data.PRODUCTS[0]
    
    OPTIONS = {
        'org': ORG['name'],
        'name': PROD['name']
    }
    
    def setUp(self):
        self.set_action(Sync())
        self.set_module(katello.client.core.product)
        
        self.mock_options(self.OPTIONS)
        
        self.mock(self.action.api, 'sync', test_data.SYNC_RESULT_WITHOUT_ERROR)
        
        self.mock(self.module, 'get_product', self.PROD)
        self.mock(self.module, 'run_async_task_with_status')
        

    def test_finds_the_product(self):
        self.action.run()
        self.module.get_product.assert_called_once_with(self.ORG['name'], self.PROD['name'])
    
    def test_returns_with_error_when_no_product_found(self):
        self.module.get_product.return_value =  None
        self.assertEqual(self.action.run(), os.EX_DATAERR)
        
    def test_calls_sync_api(self):
        self.action.run()
        self.action.api.sync.assert_called_once_with(self.PROD['id'])

    def test_waits_for_sync(self):
        self.action.run()
        self.module.run_async_task_with_status.assert_called_once()

    def test_returns_ok_when_sync_was_successful(self):
        self.assertEqual(self.action.run(), os.EX_OK)
        
    def test_returns_error_if_sync_failed(self):
        self.mock(self.action.api, 'sync', test_data.SYNC_RESULT_WITH_ERROR)
        self.assertEqual(self.action.run(), os.EX_DATAERR)
        

