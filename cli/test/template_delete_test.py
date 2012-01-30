import unittest
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.template
from katello.client.core.template import Delete



class RequiredCLIOptionsTests(CLIOptionTestCase):
    #requires: organization, name
    #optional: environment (defaults to Library)

    def setUp(self):
        self.set_action(Delete())
        self.mock_options()

    def test_missing_org_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['delete', '--environment=dev', '--name=template_1'])

    def test_missing_name_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['delete', '--environment=dev', '--org=ACME'])

    def test_no_error_if_org_and_name_provided(self):
        self.action.process_options(['delete', '--org=ACME', '--name=template_1'])
        self.assertEqual(len(self.action.optErrors), 0)

    def test_no_error_if_org_name_and_env_provided(self):
        self.action.process_options(['delete', '--org=ACME', '--environment=dev', '--name=template_1'])
        self.assertEqual(len(self.action.optErrors), 0)



class TemplateInfoTest(CLIActionTestCase):

    ORG = test_data.ORGS[0]
    ENV = test_data.ENVS[0]
    TPL = test_data.TEMPLATES[0]

    OPTIONS = {
        'org': ORG['name'],
        'env': ENV['name'],
        'name': TPL['name'],
    }

    def setUp(self):
        self.set_action(Delete())
        self.set_module(katello.client.core.template)
        self.mock_printer()

        self.mock_options(self.OPTIONS)

        self.mock(self.module, 'get_template', self.TPL)
        self.mock(self.action.api, 'delete')

    def test_it_finds_the_template(self):
        self.action.run()
        self.module.get_template.assert_called_once_with(self.ORG['name'], self.ENV['name'], self.TPL['name'])

    def test_it_returns_error_when_template_not_found(self):
        self.mock(self.module, 'get_template', None)
        self.assertEqual(self.action.run(), os.EX_DATAERR)

    def test_it_returns_success_when_template_found(self):
        self.assertEqual(self.action.run(), os.EX_OK)

    def test_it_calls_delete_api(self):
        self.action.run()
        self.action.api.delete.assert_called_once_with(self.TPL['id'])
