import unittest
import os
from mock import Mock

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import  test_data

import katello.client.core.version
from katello.client.core.version import Info



class VersionTest(CLIActionTestCase):

    def setUp(self):
        self.set_action(Info())
        self.set_module(katello.client.core.version)
        self.mock(self.action.api, 'version_formatted', test_data.VERSION_INFO)

    def test_calls_the_api(self):
        self.run_action()
        self.action.api.version_formatted.assert_called_once()

    def test_call_returns_correct_value(self):
        self.assertEqual(self.action.run(), test_data.VERSION_INFO )

