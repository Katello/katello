import unittest
from mock import Mock
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.product
from katello.client.core.product import Promote
from katello.client.api.utils import ApiDataError


class RequiredCLIOptionsTests(CLIOptionTestCase):
    def setUp(self):
        self.set_action(Promote())
        self.mock_options()

    def test_missing_environment_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['promote', '--org=ACME', '--name=product_1'])

    def test_no_error_if_org_and_product_provided(self):
        self.action.process_options(['promote', '--org=ACME', '--name=product_1', '--environment=env_1'])
        self.assertEqual(len(self.action.optErrors), 0)


class ProductPromoteTest(CLIActionTestCase):
    ORG = test_data.ORGS[0]
    ENV = test_data.ENVS[0]
    PROV = test_data.PROVIDERS[2]
    PROD = test_data.PRODUCTS[0]
    CSET = test_data.EMPTY_CHANGESET
    TMP_CHANGESET_NAME = 'tmp_changeset_name'

    OPTIONS = {
        'org': ORG['name'],
        'name': PROD['name'],
        'env': ENV['name']
    }


    def setUp(self):
        self.set_action(Promote())
        self.set_module(katello.client.core.product)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.action.csapi, 'create', self.CSET)
        self.mock(self.action.csapi, 'add_content')
        self.mock(self.action.csapi, 'promote', test_data.SYNC_RESULT_WITHOUT_ERROR)
        self.mock(self.action.csapi, 'delete')

        self.mock(self.action, 'create_cs_name', self.TMP_CHANGESET_NAME)

        self.mock(self.module, 'get_environment', self.ENV)
        self.mock(self.module, 'get_product', self.PROD)
        self.mock(self.module, 'run_spinner_in_bg', test_data.SYNC_RESULT_WITHOUT_ERROR)

    def tearDown(self):
        self.restore_mocks()

    def test_it_finds_the_environment(self):
        self.run_action()
        self.module.get_environment.assert_called_once_with(self.ORG['name'], self.ENV['name'])

    def test_it_returns_with_error_when_no_environment_found(self):
        self.mock(self.module, 'get_environment').side_effect = ApiDataError()
        self.run_action(os.EX_DATAERR)

    def test_it_finds_the_product(self):
        self.run_action()
        self.module.get_product.assert_called_once_with(self.ORG['name'], self.PROD['name'])

    def test_it_returns_with_error_when_no_product_found(self):
        self.mock(self.module, 'get_product').side_effect = ApiDataError()
        self.run_action(os.EX_DATAERR)

    def test_it_creates_new_changeset(self):
        self.run_action()
        self.action.csapi.create.assert_called_once_with(self.ORG['name'], self.ENV['id'], self.TMP_CHANGESET_NAME)

    def test_it_updates_the_changeset(self):
        self.run_action()
        self.action.csapi.add_content.assert_called_once_with(self.CSET['id'], 'products',
                {'product_id': self.PROD['id']})

    def test_it_promotes_the_changeset(self):
        self.run_action()
        self.action.csapi.promote.assert_called_once_with(self.CSET['id'])

    def test_waits_for_promotion(self):
        self.run_action()
        self.module.run_spinner_in_bg.assert_called_once()

