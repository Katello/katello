import unittest
from mock import Mock
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase,\
        CLIActionTestCase
from katello.tests.core.content_view_definition import content_view_definition_data
from katello.tests.core.organization import organization_data
from katello.tests.core.repo import repo_data
from katello.tests.core.product import product_data
import katello.client.core.filter
from katello.client.api.content_view_definition import ContentViewDefinitionAPI
from katello.client.core.filter import AddRemoveProduct
from katello.client.api.utils import ApiDataError


class RequiredCLIOptionsTest(object):

    disallowed_options = [
        ('--org=ACME', '--name=def1', "--definition=foo"),
        ('--org=ACME', '--name=def1', '--product=photoshop'),
        ('--namel=def1', '--product=photoshop', "--definition=foo")
    ]

    allowed_options = [
        ('--org=ACME', '--name=def1',  '--product=photoshop', "--definition=foo")
    ]

class AddRequiredCLIOptionsTest(RequiredCLIOptionsTest, CLIOptionTestCase):
    action = AddRemoveProduct(True)

class RemoveRequiredCLIOptionsTest(RequiredCLIOptionsTest, CLIOptionTestCase):
    action = AddRemoveProduct(False)

class FilterAddRemoveProductTest(object):
    ORG = organization_data.ORGS[0]
    PRODUCT = product_data.PRODUCTS[0]
    PRODUCTS = product_data.PRODUCTS
    DEFINITION = content_view_definition_data.DEFS[0]
    FILTER = content_view_definition_data.FILTERS[0]

    OPTIONS = {
        'org': ORG['name'],
        'label': DEFINITION['label'],
        'product': PRODUCT['label'],
        'definition': DEFINITION["name"],
    }

    addition = True

    def setUp(self):
        self.set_action(AddRemoveProduct(self.addition))
        self.set_module(katello.client.core.filter)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.module, 'get_cv_definition', self.DEFINITION)
        self.mock(self.module, 'get_filter', self.FILTER)
        self.mock(ContentViewDefinitionAPI, 'all_products', self.PRODUCTS)
        self.mock(self.action.api, 'products', self.PRODUCTS)
        self.mock(self.action.api, 'update_products')

    def test_it_returns_with_error_if_no_def_was_found(self):
        self.mock(self.module, 'get_cv_definition').side_effect = ApiDataError()
        self.run_action(os.EX_DATAERR)

    def test_it_returns_with_error_if_no_filter_was_found(self):
        self.mock(self.module, 'get_filter').side_effect = ApiDataError()
        self.run_action(os.EX_DATAERR)

    def test_it_returns_with_error_if_product_was_not_found(self):
        self.mock(self.action, 'identify_product').side_effect = ApiDataError()
        self.run_action(os.EX_DATAERR)

    def test_it_retrieves_all_definition_products(self):
        self.mock(self.action, 'identify_product', return_value = self.PRODUCT)
        self.run_action()
        self.action.api.products.assert_called_once_with(self.FILTER['id'],
                                 self.DEFINITION['id'], self.ORG['name'])
        self.action.identify_product.assert_called_once_with(self.DEFINITION,
                self.PRODUCT['name'], None, None)

class FilterAddProductTest(FilterAddRemoveProductTest, CLIActionTestCase):
    addition = True
    def test_it_calls_update_api(self):
        repos = [r['id'] for r in self.PRODUCTS + [self.PRODUCT]]
        self.run_action()
        self.action.api.update_products.assert_called_once_with(self.FILTER['id'],
             self.DEFINITION['id'], self.ORG["name"], repos)

class FilterRemoveProductTest(FilterAddRemoveProductTest, CLIActionTestCase):
    addition = False
    def test_it_calls_update_api(self):
        repos = [r['id'] for r in self.PRODUCTS if r['name'] != self.PRODUCT['name']]
        self.run_action()
        self.action.api.update_products.assert_called_once_with(self.FILTER['id'],
             self.DEFINITION['id'], self.ORG['name'], repos)
