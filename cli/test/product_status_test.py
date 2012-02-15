import unittest
from mock import Mock
import os

from cli_test_utils import CLIActionTestCase
import test_data

import katello.client.core.product
from katello.client.core.product import Status


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
        self.set_action(Status())
        self.set_module(katello.client.core.product)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'last_sync_status', test_data.SYNC_RESULT_WITHOUT_ERROR)

        self.product = self.mock(self.module, 'get_product', self.PROD).return_value

    def tearDown(self):
        self.restore_mocks()

    def test_it_finds_the_product(self):
        self.action.run()
        self.module.get_product.assert_called_once_with(self.ORG['name'], self.PROD['name'])

    def test_it_returns_with_error_when_no_product_found(self):
        self.module.get_product.return_value =  None
        self.action.run()
        self.assertEqual(self.action.run(), os.EX_DATAERR)

    def test_it_calls_last_sync_status_api(self):
        self.action.run()
        self.action.api.last_sync_status.assert_called_once_with(self.ORG['name'], self.PROD['id'])

    def test_it_does_not_set_progress_for_not_running_sync(self):
        self.action.run()
        self.assertRaises(KeyError, lambda: self.product['progress'] )

    def test_it_sets_progress_for_running_sync(self):
        self.mock(self.action.api, 'last_sync_status', test_data.SYNC_RUNNING_RESULT)
        self.action.run()
        self.assertTrue(isinstance(self.product['progress'], str))
