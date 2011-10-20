import unittest
from mock import Mock
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.product
from katello.client.core.product import AddFilter



class RequiredCLIOptionsTests(CLIOptionTestCase):

    def setUp(self):
        self.set_action(AddFilter())
        self.mock_options()

    def test_missing_org_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['add_filters', '--name=product_1', '--filter=filter1'])

    def test_missing_product_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['add_filters', '--org=ACME', '--filter=filter1'])
        
    def test_missing_filter_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['add_filters', '--org=ACME', '--name=product_1'])

    def test_no_error_if_org_and_product_provided(self):
        self.action.process_options(['add_filters', '--org=ACME', '--name=product_1', '--filter=filter1'])
        self.assertEqual(len(self.action.optErrors), 0)


class ProductListFiltersTest(CLIActionTestCase):

    ORG = test_data.ORGS[0]
    PROD = test_data.PRODUCTS[0]
    FILTER = 'filter'
    FILTER1 = 'filter_1'
    FILTER2 = 'filter_2'
    EXISTING_FILTERS = [{'name':FILTER1}, {'name':FILTER2}]

    OPTIONS = {
        'org': ORG['name'],
        'name': PROD['name'],
        'filter': FILTER
    }
    
    def setUp(self):
        self.set_action(AddFilter())
        self.set_module(katello.client.core.product)
        self.mock_printer()

        self.mock_options(self.OPTIONS)
        
        self.mock(self.action.filterAPI, 'info', {})
        self.mock(self.action.api, 'filters', self.EXISTING_FILTERS)
        self.mock(self.action.api, 'update_filters')
        self.mock(self.module, 'get_product', self.PROD)

    def test_it_returns_with_error_if_no_product_was_found(self):
        self.module.get_product.return_value =  None
        self.action.run()
        self.assertEqual(self.action.run(), os.EX_DATAERR)

    def test_it_uses_filter_api_to_retrieve_filter_info(self):
        self.action.run()
        self.action.filterAPI.info.assert_called_once_with(self.ORG['cp_key'], self.FILTER)
            
    def test_it_returns_with_error_if_filter_was_not_found(self):
        self.action.filterAPI.info.return_value =  None
        self.action.run()
        self.assertEqual(self.action.run(), os.EX_DATAERR)
        
    def test_it_retrieves_all_product_filters(self):
        self.action.run()
        self.action.api.filters.assert_called_once_with(self.PROD['id'])
                
    def test_it_calls_update_filter_api(self):
        self.action.run()
        self.action.api.update_filters.assert_called_once_with(self.PROD['id'], [self.FILTER1, self.FILTER2, self.FILTER])
        