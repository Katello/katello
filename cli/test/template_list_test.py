import unittest
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.template
from katello.client.core.template import List
from katello.client.api.utils import ApiDataError


class RequiredCLIOptionsTests(CLIOptionTestCase):
    #requires: organization
    #optional: environment (defaults to Library)

    def setUp(self):
        self.set_action(List())
        self.mock_options()

    def test_missing_org_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['list', '--environment=dev'])

    def test_no_error_if_org_provided(self):
        self.action.process_options(['list', '--org=ACME'])
        self.assertEqual(len(self.action.optErrors), 0)

    def test_no_error_if_org_and_env_provided(self):
        self.action.process_options(['list', '--org=ACME', '--environment=dev'])
        self.assertEqual(len(self.action.optErrors), 0)



class TemplateListTest(CLIActionTestCase):

    ORG = test_data.ORGS[0]
    ENV = test_data.ENVS[0]

    OPTIONS = {
        'org': ORG['name'],
        'env': ENV['name'],
    }

    def setUp(self):
        self.set_action(List())
        self.set_module(katello.client.core.template)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.action.api, 'templates', test_data.TEMPLATES)
        self.mock(self.module, 'get_environment', self.ENV)

    def test_it_finds_environment(self):
        self.run_action()
        self.module.get_environment.assert_called_once_with(self.ORG['name'], self.ENV['name'])

    def test_it_returns_error_when_environment_not_found(self):
        self.mock(self.module, 'get_environment').side_effect = ApiDataError
        self.run_action(os.EX_DATAERR)

    def test_it_calls_templates_api(self):
        self.run_action()
        self.action.api.templates.assert_called_once_with(self.ENV['id'])

    def test_it_prints_the_templates(self):
        self.run_action()
        self.action.printer.print_items.assert_called_once_with(test_data.TEMPLATES)
