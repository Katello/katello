import unittest
import os

from cli_test_utils import CLIActionTestCase
import test_data

import katello.client.core.product
from katello.client.core.product import Delete
from katello.client.api.utils import ApiDataError


class DeleteTest(CLIActionTestCase):

    ORG = test_data.ORGS[0]
    PROD = test_data.PRODUCTS[0]

    OPTIONS = {
        'org': ORG['name'],
        'name': PROD['name']
    }

    def setUp(self):
        self.set_action(Delete())
        self.set_module(katello.client.core.product)

        self.mock_options(self.OPTIONS)

        self.mock(self.module, 'get_product', self.PROD)
        self.mock(self.action.api, 'delete')


    def test_it_finds_the_product(self):
        self.run_action()
        self.module.get_product.assert_called_once_with(self.ORG['name'], self.PROD['name'])

    def test_it_returns_error_when_product_not_found(self):
        self.mock(self.module, 'get_product').side_effect = ApiDataError
        self.run_action(os.EX_DATAERR)

    def test_it_calls_delete_api(self):
        self.run_action()
        self.action.api.delete.assert_called_once_with(self.ORG['name'], self.PROD['id'])

    def test_it_returns_status_ok(self):
        self.run_action(os.EX_OK)
