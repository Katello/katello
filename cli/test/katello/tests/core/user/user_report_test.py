import unittest
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase

import katello.client.core.user
from katello.client.core.user import Report
from katello.client.core.utils import convert_to_mime_type

class UserReportTest(CLIActionTestCase):

    def setUp(self):
        self.set_action(Report())
        self.set_module(katello.client.core.user)
        self.mock(self.action.api, 'report', ('', ''))
        self.mock(self.module, 'save_report')

    def tearDown(self):
        self.restore_mocks()

    def test_it_calls_report_api_with_default_format(self):
        self.run_action()
        self.action.api.report.assert_called_once_with('text/plain')

    def test_it_uses_format_parameter(self):
        self.mock_options({'format': 'pdf'})
        self.run_action()
        self.action.api.report.assert_called_once_with(convert_to_mime_type('pdf'))

    def test_it_saves_pdf_report(self):
        self.mock_options({'format': 'pdf'})
        self.run_action()
        self.module.save_report.assert_called_once()
