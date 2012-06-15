import unittest
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase
from katello.tests.core.organization import organization_data

import katello.client.core.system
from katello.client.core.system import Report
from katello.client.core.utils import convert_to_mime_type

class RequiredCLIOptionsTests(CLIOptionTestCase):
    #requires: organization
    #optional: environment (defaults to Library)

    action = Report()

    disallowed_options = [
        (),
    ]

    allowed_options = [
        ('--org=ACME', ),
        ('--org=ACME', '--environment=dev'),
    ]

class SystemReportTest(CLIActionTestCase):

    ORG_ID = 'some_org'
    ENV = organization_data.ENVS[1]
    ENV_NAME = ENV['name']
    ENV_ID = ENV['id']

    def setUp(self):
        self.set_action(Report())
        self.set_module(katello.client.core.system)
        self.mock(self.action.api, 'report_by_org', ('', ''))
        self.mock(self.action.api, 'report_by_env', ('', ''))
        self.mock(self.module, 'save_report')
        self.mock(self.module, 'get_environment', self.ENV)


    def test_it_calls_report_api_with_default_format(self):
        self.mock_options({'org': self.ORG_ID})
        self.run_action()
        self.action.api.report_by_org.assert_called_once_with(self.ORG_ID, 'text/plain')

    def test_it_uses_format_parameter(self):
        self.mock_options({'org': self.ORG_ID, 'format': 'pdf'})
        self.run_action()
        self.action.api.report_by_org.assert_called_once_with(self.ORG_ID, convert_to_mime_type('pdf'))

    def test_it_saves_pdf_report(self):
        self.mock_options({'org': self.ORG_ID, 'format': 'pdf'})
        self.run_action()
        self.module.save_report.assert_called_once()

    def test_it_calls_report_by_env_api(self):
        self.mock_options({'org': self.ORG_ID, 'environment': self.ENV_NAME})
        self.run_action()
        self.action.api.report_by_env.assert_called_once_with(self.ENV_ID, 'text/plain')
