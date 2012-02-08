import unittest
from mock import Mock
import os

from cli_test_utils import CLIActionTestCase
import test_data

import katello.client.core.product
from katello.client.core.product import CancelSync


class ProductStatusTest(CLIActionTestCase):

    ORG = test_data.ORGS[0]
    PROV = test_data.PROVIDERS[2]
    PROD = test_data.PRODUCTS[0]

    OPTIONS = {
        'org': ORG['name'],
        'name': PROD['name']
    }

    product = None

    def setUp(self):
        self.set_action(CancelSync())
        self.set_module(katello.client.core.product)

        self.mock_options(self.OPTIONS)
        self.mock(self.action.api, 'cancel_sync')
        self.mock(self.module, 'get_product', self.PROD)


    def test_it_finds_the_product(self):
        self.action.run()
        self.module.get_product.assert_called_once_with(self.ORG['name'], self.PROD['name'])

    def test_it_returns_with_error_when_no_product_found(self):
        self.module.get_product.return_value =  None
        self.assertEqual(self.action.run(), os.EX_DATAERR)

    def test_it_calls_cancel_sync_api(self):
        self.action.run()
        self.action.api.cancel_sync.assert_called_once_with(self.ORG['name'], self.PROD['id'])

    def test_it_returns_ok(self):
        self.assertEqual(self.action.run(), os.EX_OK)
