import unittest
from mock import Mock
import urlparse
from cli_test_utils import CLIOptionTestCase, CLIActionTestCase

import katello.client.core.repo
from katello.client.core.organization import GenerateDebugCert

class RequiredCLIOptionsTests(CLIOptionTestCase):
    def setUp(self):
        self.set_action(GenerateDebugCert())
        self.mock_options()

    def test_missing_name_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['uebercert'])

    def test_no_error_if_required_options_provided(self):
        self.action.process_options(['uebercert', '--name=org'])
        self.assertEqual(len(self.action.optErrors), 0)

class CreateUebercertTest(CLIActionTestCase):
    NAME = 'ORG'

    def setUp(self):
        self.set_action(GenerateDebugCert())
        self.set_module(katello.client.core.organization)
        self.mock_printer()

        self.mock_options({ 'name': self.NAME })

        self.action.api.uebercert = Mock()

    def tearDown(self):
        self.restore_mocks()

    def test_generates_uebercert_in_cp(self):
        self.run_action()
        self.action.api.uebercert.assert_called_once_with(self.NAME, None)
