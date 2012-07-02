import unittest
from mock import Mock
import os

from katello.tests.core.action_test_utils import CLIActionTestCase

from katello.tests.core.organization import organization_data
from katello.tests.core.product import product_data
from katello.tests.core.provider import provider_data
from katello.tests.core.repo import repo_data

import katello.client.core.product
from katello.client.core.product import Sync
from katello.client.api.utils import ApiDataError


class ProductSyncTest(CLIActionTestCase):

    ORG = organization_data.ORGS[0]
    ENV = organization_data.ENVS[0]
    PROV = provider_data.PROVIDERS[2]
    PROD = product_data.PRODUCTS[0]

    OPTIONS = {
        'org': ORG['name'],
        'name': PROD['name']
    }

    def setUp(self):
        self.set_action(Sync())
        self.set_module(katello.client.core.product)

        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'sync', repo_data.SYNC_RESULT_WITHOUT_ERROR)

        self.mock(self.module, 'get_product', self.PROD)
        self.mock(self.module, 'run_async_task_with_status')


    def test_finds_the_product(self):
        self.run_action()
        self.module.get_product.assert_called_once_with(self.ORG['name'], self.PROD['name'])

    def test_returns_with_error_when_no_product_found(self):
        self.mock(self.module, 'get_product').side_effect = ApiDataError()
        self.run_action(os.EX_DATAERR)

    def test_calls_sync_api(self):
        self.run_action()
        self.action.api.sync.assert_called_once_with(self.ORG['name'], self.PROD['id'])

    def test_waits_for_sync(self):
        self.run_action()
        self.module.run_async_task_with_status.assert_called_once()

    def test_returns_ok_when_sync_was_successful(self):
        self.run_action(os.EX_OK)

    def test_returns_error_if_sync_failed(self):
        self.mock(self.action.api, 'sync', repo_data.SYNC_RESULT_WITH_ERROR)
        self.run_action(os.EX_DATAERR)
