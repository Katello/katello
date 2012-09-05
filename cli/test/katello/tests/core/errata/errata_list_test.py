import unittest
import os
from mock import Mock

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase

from katello.tests.core.errata.errata_data import *
from katello.tests.core.organization.organization_data import ORGS, ENVS
from katello.tests.core.product.product_data import PRODUCTS
from katello.tests.core.repo.repo_data import REPOS

from katello.client.api import utils
import katello.client.core.errata
from katello.client.core.errata import List



class RequiredCLIOptionsTests(CLIOptionTestCase):

    action = List()

    disallowed_options = [
        ('--repo=repo-123', '--product=product-123'),
        ('--repo=repo-123', '--org=org-123'),
        ('--product=product-123', ),
        (),
    ]

    allowed_options = [
        ('--repo=repo-123', '--product=product-123', '--org=org-123'),
        ('--repo_id=repo-123', ),
        ('--org=org-123', ),
        ('--org=org-123', '--environment=env-123', '--product=product-123'),
        ('--type=enhancements', '--org=org-123'),
        ('--severity=critical', '--org=org-123'),
    ]


class ErrataListTest(CLIActionTestCase):

    ORG = ORGS[0]
    ENV = ENVS[0]
    PRODUCT = PRODUCTS[0]
    REPO = REPOS[0]

    OPTIONS_BY_PRODUCT_AND_REPO = {
        'org': ORG['name'],
        'product': PRODUCT['name'],
        'repo': REPO['name']
    }

    OPTIONS_BY_TYPE = {
        'org': ORG['name'],
        'product': PRODUCT['name'],
        'repo': REPO['name'],
        'type': 'enhancements'
    }

    OPTIONS_BY_ORG = { 'org': ORG['name'] }

    OPTIONS_BY_ORG_AND_PRODUCT = { 'org': ORG['name'], 'product': PRODUCT['name'] }

    OPTIONS_BY_ENV = { 'org': ORG['name'], 'environment': ENV['name'] }

    OPTIONS_BY_SEVERITY = {
        'org': ORG['name'],
        'product': PRODUCT['name'],
        'repo': REPO['name'],
        'severity': 'critical',
    }


    def setUp(self):
        self.set_action(List())
        self.set_module(katello.client.core.errata)

        self.mock_printer()

        self.mock(self.module, 'get_repo', self.REPO)
        self.mock(self.action.api, 'errata_filter', ERRATA_BY_REPO)
        self.mock(self.module, 'get_environment', self.ENV)
        self.mock(self.module, 'get_product', self.PRODUCT)

    def tearDown(self):
        self.restore_mocks()

    def test_it_prints_errata(self):
        self.mock_options(self.OPTIONS_BY_PRODUCT_AND_REPO)
        self.run_action()
        self.action.printer.print_items.assert_called_once_with(ERRATA_BY_REPO)

    def test_it_uses_library_when_no_env_is_specified(self):
        self.mock_options(self.OPTIONS_BY_ORG)
        self.run_action()
        self.module.get_environment.assert_called_once_with(self.OPTIONS_BY_ORG['org'], None)

    def test_it_searches_for_env_id_when_env_is_specified(self):
        self.mock_options(self.OPTIONS_BY_ENV)
        self.run_action()
        self.module.get_environment.assert_called_once_with(self.OPTIONS_BY_ENV['org'], self.OPTIONS_BY_ENV['environment'])

    def test_it_searches_for_product_id_when_product_specified(self):
        self.mock_options(self.OPTIONS_BY_ORG_AND_PRODUCT)
        self.run_action()
        self.module.get_environment.assert_called_once_with(self.OPTIONS_BY_ORG_AND_PRODUCT['org'], None)
        self.module.get_product.assert_called_once_with(self.OPTIONS_BY_ORG_AND_PRODUCT['org'], self.OPTIONS_BY_ORG_AND_PRODUCT['product'])
        self.action.api.errata_filter.assert_called_once_with(repo_id=None, type_in=None, environment_id=self.ENV['id'], prod_id=self.PRODUCT['id'], severity=None)

    def test_it_supports_filtering_by_type(self):
        self.mock_options(self.OPTIONS_BY_TYPE)
        self.run_action()
        self.action.api.errata_filter.assert_called_once_with(repo_id=self.REPO['id'], type_in=self.OPTIONS_BY_TYPE['type'], environment_id=None, prod_id=None, severity=None)

    def test_it_supports_filtering_by_severity(self):
        self.mock_options(self.OPTIONS_BY_SEVERITY)
        self.run_action()
        self.action.api.errata_filter.assert_called_once_with(repo_id=self.REPO['id'], type_in=None, environment_id=None, prod_id=None, severity=self.OPTIONS_BY_SEVERITY['severity'])
