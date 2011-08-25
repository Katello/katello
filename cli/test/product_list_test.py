import unittest
import os
from mock import Mock
from cli_test_utils import CLIOptionTestCase, CLIActionTestCase

import katello.client.core.product
from katello.client.core.product import List



class RequiredCLIOptionsTests(CLIOptionTestCase):
    
    def setUp(self):
        self.set_action(List())
        self.mock_options()

    def test_missing_org_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['synchronize', '--environment=env'])

    def test_no_error_if_org_provided(self):
        self.action.process_options(['list', '--org=ACME'])
        self.assertEqual(len(self.action.optErrors), 0)

    def test_no_error_if_org_and_env_provided(self):
        self.action.process_options(['list', '--org=ACME', '--environment=env'])
        self.assertEqual(len(self.action.optErrors), 0)
        
    def test_no_error_if_org_and_provider_provided(self):
        self.action.process_options(['list', '--org=ACME', '--provider=prov'])
        self.assertEqual(len(self.action.optErrors), 0)



class ProductListTest(CLIActionTestCase):
    ORG_NAME = 'ACME'
    ENV_NAME = 'production'
    PROV_NAME = 'provider_1'
    PROV_ID = 83


    OPTIONS_BY_ENV = {
        'org': ORG_NAME,
        'env': ENV_NAME
    }

    OPTIONS_BY_PROVIDER = {
        'org': ORG_NAME,
        'prov': PROV_NAME
    }
    
    ENV = {
        'name': ENV_NAME,
        'id': 83
    }
    
    PROVIDER = {
        'name': PROV_NAME,
        'id': PROV_ID
    }
    
    PRODUCTS = [
        {
            'name': 'prod_1',
            'provider_id': PROV_ID,
            'provider_name': PROV_NAME
        },
        {
            'name': 'prod_2',
            'provider_id': 2,
            'provider_name': PROV_NAME
        }
    ]

    def setUp(self):        
        self.set_action(List())
        self.set_module(katello.client.core.product)
        
        self.mock_options(self.OPTIONS_BY_ENV)
        self.mock_printer()
        
        self.mock(self.action.api, 'products_by_env', self.PRODUCTS)
        self.mock(self.action.api, 'products_by_provider', self.PRODUCTS)
        
        self.mock(self.module, 'get_environment', self.ENV)
        self.mock(self.module, 'get_provider', self.PROVIDER)
        
    def tearDown(self):
        self.restore_mocks()
        
        
    def test_it_finds_environment(self):
        self.mock_options(self.OPTIONS_BY_ENV)
        self.action.run()
        self.module.get_environment.assert_called_once_with(self.ORG_NAME, self.ENV_NAME)


    def test_it_finds_products_by_environment(self):
        self.mock_options(self.OPTIONS_BY_ENV)
        self.action.run()
        self.action.api.products_by_env.assert_called_once_with(self.ENV['id'])

    def test_it_finds_provider(self):
        self.mock_options(self.OPTIONS_BY_PROVIDER)
        self.action.run()
        self.module.get_provider.assert_called_once_with(self.ORG_NAME, self.PROVIDER['name'])

    def test_it_finds_products_by_provider(self):
        self.mock_options(self.OPTIONS_BY_PROVIDER)
        self.action.run()
        self.action.api.products_by_provider.assert_called_once_with(self.PROVIDER['id'])

    def test_it_prints_products(self):
        self.action.run()
        self.action.printer.printItems.assert_called_once_with(self.PRODUCTS)

