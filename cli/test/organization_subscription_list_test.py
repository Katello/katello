import unittest
import os
from mock import Mock

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.organization
from katello.client.core.organization import ShowSubscriptions



class RequiredCLIOptionsTests(CLIOptionTestCase):

    def setUp(self):
        self.set_action(ShowSubscriptions())
        self.mock_options()

    def test_missing_org_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['subscriptions'])

    def test_no_error_if_org_provided(self):
        self.action.process_options(['subscriptions', '--name=ACME'])
        self.assertEqual(len(self.action.optErrors), 0)



class SubscriptionsListTest(CLIActionTestCase):

    ORGANIZATION = 'org'
    OPTIONS = { 'name': ORGANIZATION }

    def setUp(self):
        self.set_action(ShowSubscriptions())
        self.set_module(katello.client.core.organization)

        self.mock_options(self.OPTIONS)
        self.mock_printer()

        self.mock(self.action.api, 'pools', [test_data.POOL])
        self.mock(self.action.productApi, 'product_by_name', test_data.PRODUCTS[0])

    def tearDown(self):
        self.restore_mocks()

    def test_it_finds_all_pools_for_organization(self):
        self.action.run()
        self.action.api.pools.assert_called_once_with(self.ORGANIZATION)

    def test_it_calls_add_sla(self):
        self.mock(self.action, 'add_sla', [])
        self.action.run()
        self.action.add_sla.assert_called_once_with(self.ORGANIZATION, [test_data.POOL])

    def test_add_sla_adds_sla_field_if_it_exists(self):
        pools_with_sla = self.action.add_sla(self.ORGANIZATION, [test_data.POOL])

        self.assertEqual(1, len(pools_with_sla))
        self.assertEqual(test_data.PRODUCTS[0]['attributes'][0]['value'], pools_with_sla[0]['sla'])

    def test_add_an_empty_sla_field_if_it_is_not_present(self):
        self.mock(self.action.productApi, 'product_by_name', test_data.PRODUCTS[1])
        pools_with_sla = self.action.add_sla(self.ORGANIZATION, [test_data.POOL])

        self.assertEqual(1, len(pools_with_sla))
        self.assertEqual("", pools_with_sla[0]['sla'])


    
