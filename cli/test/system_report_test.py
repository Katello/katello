import unittest
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.system
from katello.client.core.system import Report
from katello.client.core.utils import convert_to_mime_type
 
class UserReportTest(CLIActionTestCase):

    def setUp(self):
        self.set_action(Report())
        self.set_module(katello.client.core.system)
        self.mock(self.action.api, 'report', '')
 
    def tearDown(self):
        self.restore_mocks()

    def test_it_calls_report_api_with_default_format(self):
        self.action.run()
        self.action.api.report.assert_called_once_with('text/plain')        

    def test_it_uses_format_parameter(self):
        self.mock_options({'format': 'pdf'})        
        self.action.run()
        self.action.api.report.assert_called_once_with(convert_to_mime_type('pdf'))
