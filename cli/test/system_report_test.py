import unittest
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.system
from katello.client.core.system import Report
from katello.client.core.utils import convert_to_mime_type

class RequiredCLIOptionsTests(CLIOptionTestCase):
    #requires: organization
    #optional: environment (defaults to Library)

    def setUp(self):
        self.set_action(Report())
        self.mock_options()

    def test_missing_org_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['report'])

    def test_no_error_if_org_provided(self):
        self.action.process_options(['report', '--org=ACME'])
        self.assertEqual(len(self.action.optErrors), 0)

    def test_no_error_if_org_and_env_provided(self):
        self.action.process_options(['list', '--org=ACME', '--environment=dev'])
        self.assertEqual(len(self.action.optErrors), 0)

class UserReportTest(CLIActionTestCase):

    ORG_ID = 'some_org'
    ENV_NAME = 'env'

    def setUp(self):
        self.set_action(Report())
        self.set_module(katello.client.core.system)
        self.mock(self.action.api, 'report_by_org', ('', ''))
        self.mock(self.action.api, 'report_by_env', ('', ''))
        self.mock(self.module, 'save_report')

    def tearDown(self):
        self.restore_mocks()

    def test_it_calls_report_api_with_default_format(self):
        self.mock_options({'org': self.ORG_ID})
        self.action.run()
        self.action.api.report_by_org.assert_called_once_with(self.ORG_ID, 'text/plain')

    def test_it_uses_format_parameter(self):
        self.mock_options({'org': self.ORG_ID, 'format': 'pdf'})
        self.action.run()
        self.action.api.report_by_org.assert_called_once_with(self.ORG_ID, convert_to_mime_type('pdf'))

    def test_it_saves_pdf_report(self):
        self.mock_options({'org': self.ORG_ID, 'format': 'pdf'})
        self.action.run()
        self.module.save_report.assert_called_once()

    def test_it_calls_report_by_env_api(self):
        self.mock_options({'org': self.ORG_ID, 'environment': self.ENV_NAME})
        self.action.run()
        self.action.api.report_by_env.assert_called_once_with(self.ORG_ID, self.ENV_NAME, 'text/plain')
