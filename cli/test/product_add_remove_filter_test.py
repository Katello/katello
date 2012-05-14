import unittest
from mock import Mock
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.product
from katello.client.core.product import AddRemoveFilter
from katello.client.api.utils import ApiDataError


class RequiredCLIOptionsTest(object):

    def test_missing_org_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['add_filters', '--name=product_1', '--filter=filter_1'])

    def test_missing_product_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['add_filters', '--org=ACME', '--filter=filter_1'])

    def test_missing_filter_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['add_filters', '--org=ACME', '--name=product_1'])

    def test_no_error_if_org_and_product_provided(self):
        self.action.process_options(['add_filters', '--org=ACME', '--name=product_1', '--filter=filter1'])
        self.assertEqual(len(self.action.optErrors), 0)


class AddRequiredCLIOptionsTest(RequiredCLIOptionsTest, CLIOptionTestCase):
    #repo is defined by either (org, product, repo_name, env name) or repo_id
    def setUp(self):
        self.set_action(AddRemoveFilter(True))
        self.mock_options()


class RemoveRequiredCLIOptionsTest(RequiredCLIOptionsTest, CLIOptionTestCase):
    #repo is defined by either (org, product, repo_name, env name) or repo_id
    def setUp(self):
        self.set_action(AddRemoveFilter(False))
        self.mock_options()



class ProductAddRemoveFilterTest(object):

    ORG = test_data.ORGS[0]
    PROD = test_data.PRODUCTS[0]
    FILTERS = test_data.FILTERS
    FILTER = FILTERS[0]

    OPTIONS = {
        'org': ORG['name'],
        'name': PROD['name'],
        'filter': FILTER['name']
    }

    addition = True

    def setUp(self):
        self.set_action(AddRemoveFilter(self.addition))
        self.set_module(katello.client.core.product)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'filters', self.FILTERS)
        self.mock(self.action.api, 'update_filters')

        self.mock(self.module, 'get_product', self.PROD)
        self.mock(self.module, 'get_filter', self.FILTER)


    def test_it_returns_with_error_if_no_product_was_found(self):
        self.mock(self.module, 'get_product').side_effect = ApiDataError()
        self.run_action(os.EX_DATAERR)

    def test_it_returns_with_error_if_filter_was_not_found(self):
        self.mock(self.module, 'get_filter').side_effect = ApiDataError()
        self.run_action(os.EX_DATAERR)

    def test_it_retrieves_all_product_filters(self):
        self.run_action()
        self.action.api.filters.assert_called_once_with(self.ORG['name'], self.PROD['id'])


class ProductAddFilterTest(ProductAddRemoveFilterTest, CLIActionTestCase):
    addition = True

    def test_it_calls_update_api(self):
        filters = [f['name'] for f in self.FILTERS + [self.FILTER]]
        self.run_action()
        self.action.api.update_filters.assert_called_once_with(self.ORG['name'], self.PROD['id'], filters)


class ProductRemoveFilterTest(ProductAddRemoveFilterTest, CLIActionTestCase):
    addition = False

    def test_it_calls_update_api(self):
        filters = [f['name'] for f in self.FILTERS if f['name'] != self.FILTER['name']]
        self.run_action()
        self.action.api.update_filters.assert_called_once_with(self.ORG['name'], self.PROD['id'], filters)
