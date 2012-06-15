import unittest
from mock import Mock
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase

from katello.tests.core.organization import organization_data
from katello.tests.core.product import product_data
from katello.tests.core.filter import filter_data

import katello.client.core.product
from katello.client.core.product import AddRemoveFilter
from katello.client.api.utils import ApiDataError


class RequiredCLIOptionsTest(object):

    disallowed_options = [
        ('--name=product_1', '--filter=filter_1'),
        ('--org=ACME', '--filter=filter_1'),
        ('--org=ACME', '--name=product_1')
    ]

    allowed_options = [
        ('--org=ACME', '--name=product_1', '--filter=filter1')
    ]


class AddRequiredCLIOptionsTest(RequiredCLIOptionsTest, CLIOptionTestCase):
    #repo is defined by either (org, product, repo_name, env name) or repo_id
    action = AddRemoveFilter(True)


class RemoveRequiredCLIOptionsTest(RequiredCLIOptionsTest, CLIOptionTestCase):
    #repo is defined by either (org, product, repo_name, env name) or repo_id
    action = AddRemoveFilter(False)



class ProductAddRemoveFilterTest(object):

    ORG = organization_data.ORGS[0]
    PROD = product_data.PRODUCTS[0]
    FILTERS = filter_data.FILTERS
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
